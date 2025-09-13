#!/bin/bash

REPO_URL="https://github.com/co-cart/co-cart.git"
CLONE_DIR="co-cart-repo"
OUTPUT_FILE="build/actions.mdx"
TEMP_COUNTS="/tmp/action_counts.txt"
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
title: Actions
description: 'Trigger an action when these hooks are called'
---

EOF

# Function to extract the comment block directly above a action
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

# Function to extract related actions
extract_related() {
  local comment_block="$1"
  local output=""
  local has_related=0

  while IFS= read -r line; do
    if [[ $line =~ \*[[:space:]]*@see[[:space:]]+([^[:space:]]+) ]]; then
      if [ $has_related -eq 0 ]; then
        output="**See Also:**\n"
        has_related=1
      fi
      local related="${BASH_REMATCH[1]}"
      output+="- \`$related\`\n"
    fi
  done <<< "$comment_block"

  if [ $has_related -eq 1 ]; then
    echo -e "$output"
  fi
}

# Function to generate example code
generate_example() {
  local hook_name="$1"
  local params="$2"

  if [[ -z "$params" ]]; then
    echo -e "**Usage**\n\`\`\`php\ndo_action( '$hook_name', function() {\n    // Your code here\n});\n\`\`\`"
    return
  fi

  local param_list=""
  while IFS= read -r line; do
    if [[ $line =~ \|\s*\`\$([^`]+)\`[^|]+\|\s*\`([^`]+)\` ]]; then
      param_list+="\$${BASH_REMATCH[1]}, "
    fi
  done <<< "$params"
  param_list=${param_list%, }

  echo -e "**Usage**\n\`\`\`php\ndo_action( '$hook_name', function($param_list) {\n    // Your code here\n}, 10, ${param_list//[^,]/1});\n\`\`\`"
}

# Function to increment counter
increment_counter() {
  local counter_file="$1"
  local current=$(<"$counter_file")
  echo $((current + 1)) > "$counter_file"
}

echo "Scanning for CoCart-specific actions..."

# Find both regular actions and deprecated actions
grep -rnE "(do_action|cocart_do_deprecated_action)\s*\(\s*['\"](cocart_[a-zA-Z0-9_\-]+)['\"]" "$CLONE_DIR" --include="*.php" | while IFS= read -r match; do
  ACTION_NAME=$(echo "$match" | sed -nE "s/.*['\"](cocart_[a-zA-Z0-9_\-]+)['\"].*/\1/p")
  FILE_PATH=$(echo "$match" | cut -d: -f1)
  LINE_NUMBER=$(echo "$match" | cut -d: -f2)
  RELATIVE_PATH=${FILE_PATH#$CLONE_DIR/}
  GITHUB_LINK="https://github.com/co-cart/co-cart/blob/$BRANCH/$RELATIVE_PATH#L$LINE_NUMBER"
  COMMENT_BLOCK=$(extract_comment_block "$FILE_PATH" "$LINE_NUMBER")

  # Check if this is a deprecated action
  IS_DEPRECATED=0
  if [[ $(echo "$match" | grep -c "cocart_do_deprecated_action") -eq 1 ]] || \
     [[ $(extract_comment_block "$FILE_PATH" "$LINE_NUMBER" | grep -c "@deprecated") -eq 1 ]]; then
    IS_DEPRECATED=1
  fi

  if [[ -z "$COMMENT_BLOCK" ]]; then
    increment_counter "${TEMP_COUNTS}.skipped"
    continue
  fi

  DESCRIPTION=$(echo "$COMMENT_BLOCK" | grep -Ev "@|^$|^\*/|^\s*\/\*\*" | sed 's/^[[:space:]]*\*//g' | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g' | sed 's/^ *//;s/ *$//' | sed 's/ \/ *$//' | sed 's/^Hook: //')
  SINCE=$(echo "$COMMENT_BLOCK" | grep "@since" | head -n 1 | sed -E 's/.*@since[[:space:]]+([^*]+).*/\1/' | sed 's/^ *//;s/ *$//')
  DEPRECATED=$(echo "$COMMENT_BLOCK" | grep "@deprecated" | head -n 1 | sed -E 's/.*@deprecated[[:space:]]+([^*]+).*/\1/' | sed 's/^ *//;s/ *$//')
  PARAMS=$(format_params "$COMMENT_BLOCK")
  RELATED=$(extract_related "$COMMENT_BLOCK")
  RETURN=$(echo "$COMMENT_BLOCK" | grep "@return" | head -n 1 | sed -E 's/.*@return[[:space:]]+([^*]+).*/\1/' | sed 's/^ *//;s/ *$//')

  if [[ -z "$DESCRIPTION" && -z "$SINCE" && -z "$PARAMS" ]]; then
    echo "Skipped: $ACTION_NAME (No meaningful documentation)"
    increment_counter "${TEMP_COUNTS}.skipped"
    continue
  fi

  {
    echo "## \`$ACTION_NAME\`"

    # Show deprecation notice if applicable
    if [[ $IS_DEPRECATED -eq 1 ]]; then
      echo "<Warning>**Deprecated:** ${DEPRECATED:-This action is deprecated.}</Warning>"
      echo ""
    fi

    if [[ -n "$RELATED" ]]; then
      echo -e "$RELATED"
    fi

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

    if [[ -n "$RETURN" ]]; then
      echo "-**Returns**: \`$RETURN\`"
    fi

    # Add example
    echo ""
    echo "$(generate_example "$ACTION_NAME" "$PARAMS")"
    echo ""

    echo "**Defined in**: [\`$RELATIVE_PATH\`]($GITHUB_LINK)"

    echo ""
    echo "---"
    echo ""
  } >> "$OUTPUT_FILE"

  increment_counter "${TEMP_COUNTS}.processed"
  echo "Processed: $ACTION_NAME"
done

# Read final counts
PROCESSED_COUNT=$(<"${TEMP_COUNTS}.processed")
SKIPPED_COUNT=$(<"${TEMP_COUNTS}.skipped")
TOTAL_COUNT=$((PROCESSED_COUNT + SKIPPED_COUNT))

echo "Summary:"
echo "- Processed: $PROCESSED_COUNT actions"
echo "- Skipped: $SKIPPED_COUNT actions"
echo "- Total: $TOTAL_COUNT actions"
echo "Documentation written to $OUTPUT_FILE"

# Cleanup temp files
rm "${TEMP_COUNTS}.processed" "${TEMP_COUNTS}.skipped"