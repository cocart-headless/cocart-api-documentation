#!/bin/bash

REPO_URL="https://github.com/co-cart/co-cart.git"
CLONE_DIR="co-cart-repo"
OUTPUT_FILE="build/filters.mdx"
TEMP_COUNTS="/tmp/filter_counts.txt"
BRANCH=${1:-development}  # Use first argument as branch, default to development

# Initialize counts
echo "0" > "${TEMP_COUNTS}.processed"
echo "0" > "${TEMP_COUNTS}.skipped"

# Clone the repository if not already cloned
if [ ! -d "$CLONE_DIR" ]; then
  echo "Cloning repository from $REPO_URL (branch: $BRANCH)..."
  git clone "$REPO_URL" "$CLONE_DIR"
else
  echo "Repository already cloned."
fi
cd "./$CLONE_DIR" && git checkout "$BRANCH" && cd ..

# Initialize the output file
cat > "$OUTPUT_FILE" <<EOF
---
title: Filters
description: 'These filters let you control how CoCart operates for your store'
---

EOF

# Function to extract the comment block directly above a filter
extract_comment_block() {
  local file_path="$1"
  local line_number="$2"
  
  local start_line=$((line_number - 10))
  if [ $start_line -lt 1 ]; then
    start_line=1
  fi

  sed -n "${start_line},${line_number}p" "$file_path" | awk '
    BEGIN { in_comment = 0; buffer = ""; found_code = 0 }
    
    /^[^[:space:]]*[^[:space:]*\/]/ { 
      if (!in_comment) { found_code = 1 }
    }
    
    /^\s*\/\*\*/ { 
      if (!found_code) {
        buffer = $0 "\n"
        in_comment = 1 
      }
      next
    }
    
    in_comment && /^\s*\*/ {
      buffer = buffer $0 "\n"
    }
    
    in_comment && /^\s*\*\// {
      in_comment = 0
      print buffer
    }
  '
}

# Function to clean and format parameters
format_params() {
  local comment_block="$1"
  local has_params=0
  local output=""
  
  while IFS= read -r line; do
    if [[ $line =~ \*[[:space:]]*@param[[:space:]]+([^[:space:]]+)[[:space:]]+(\$[^[:space:]]+)[[:space:]]+(.*) ]]; then
      if [ $has_params -eq 0 ]; then
        output="| Parameter | Type | Description |\n|-----------|------|-------------|\n"
        has_params=1
      fi
      local type="${BASH_REMATCH[1]}"
      local var="${BASH_REMATCH[2]}"
      local desc="${BASH_REMATCH[3]}"
      output+="| \`$var\` | \`$type\` | $desc |\n"
    fi
  done <<< "$comment_block"
  
  if [ $has_params -eq 1 ]; then
    echo -e "$output"
  fi
}

# Function to increment counter
increment_counter() {
  local counter_file="$1"
  local current=$(<"$counter_file")
  echo $((current + 1)) > "$counter_file"
}

echo "Scanning for CoCart-specific filters..."
grep -rnE "(apply_filters)\s*\(\s*['\"](cocart_[a-zA-Z0-9_\-]+)['\"]" "$CLONE_DIR" --include="*.php" | while IFS= read -r match; do
  FILTER_NAME=$(echo "$match" | sed -nE "s/.*['\"](cocart_[a-zA-Z0-9_\-]+)['\"].*/\1/p")
  FILE_PATH=$(echo "$match" | cut -d: -f1)
  LINE_NUMBER=$(echo "$match" | cut -d: -f2)
  RELATIVE_PATH=${FILE_PATH#$CLONE_DIR/}
  GITHUB_LINK="https://github.com/co-cart/co-cart/blob/$BRANCH/$RELATIVE_PATH#L$LINE_NUMBER"
  COMMENT_BLOCK=$(extract_comment_block "$FILE_PATH" "$LINE_NUMBER")

  if [[ -z "$COMMENT_BLOCK" ]]; then
    increment_counter "${TEMP_COUNTS}.skipped"
    continue
  fi

  DESCRIPTION=$(echo "$COMMENT_BLOCK" | grep -Ev "@|^$|^\*/|^\s*\/\*\*" | sed 's/^[[:space:]]*\*//g' | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g' | sed 's/^ *//;s/ *$//' | sed 's/ \/ *$//')
  SINCE=$(echo "$COMMENT_BLOCK" | grep "@since" | head -n 1 | sed -E 's/.*@since[[:space:]]+([^*]+).*/\1/' | sed 's/^ *//;s/ *$//')
  PARAMS=$(format_params "$COMMENT_BLOCK")

  if [[ -z "$DESCRIPTION" && -z "$SINCE" && -z "$PARAMS" ]]; then
    echo "Skipped: $FILTER_NAME (No meaningful documentation)"
    increment_counter "${TEMP_COUNTS}.skipped"
    continue
  fi

  {
    echo "## \`$FILTER_NAME\`"
    if [[ -n "$DESCRIPTION" ]]; then
      echo "$DESCRIPTION"
      echo ""
    fi

    if [[ -n "$PARAMS" ]]; then
      echo "$PARAMS"
      echo ""
    fi

    if [[ -n "$SINCE" ]]; then
      echo "- **Since**: $SINCE"
    fi
    echo "- **Defined in**: [\`$RELATIVE_PATH\`]($GITHUB_LINK)"
    echo ""
    echo "---"
    echo ""
  } >> "$OUTPUT_FILE"

  increment_counter "${TEMP_COUNTS}.processed"
  echo "Processed: $FILTER_NAME"
done

# Read final counts
PROCESSED_COUNT=$(<"${TEMP_COUNTS}.processed")
SKIPPED_COUNT=$(<"${TEMP_COUNTS}.skipped")
TOTAL_COUNT=$((PROCESSED_COUNT + SKIPPED_COUNT))

echo "Summary:"
echo "- Processed: $PROCESSED_COUNT filters"
echo "- Skipped: $SKIPPED_COUNT filters"
echo "- Total: $TOTAL_COUNT filters"
echo "Documentation written to $OUTPUT_FILE"

# Cleanup temp files
rm "${TEMP_COUNTS}.processed" "${TEMP_COUNTS}.skipped"