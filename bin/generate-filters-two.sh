#!/bin/bash

# Exit on error
set -e

REPO_URL="https://github.com/co-cart/co-cart.git"
CLONE_DIR="co-cart-repo"
OUTPUT_FILE="build/filters.mdx"
TEMP_COUNTS="/tmp/filter_counts.txt"
BRANCH=${1:-development}  # Use first argument as branch, default to development

# Cleanup function
cleanup() {
    rm -f "${TEMP_COUNTS}.processed" "${TEMP_COUNTS}.skipped"
}
trap cleanup EXIT

# Initialize counts
echo "0" > "${TEMP_COUNTS}.processed"
echo "0" > "${TEMP_COUNTS}.skipped"

# Create necessary directories
mkdir -p build
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Clone the repository if not already cloned
if [ ! -d "$CLONE_DIR" ]; then
    echo "Cloning repository from $REPO_URL (branch: $BRANCH)..."
    if ! git clone "$REPO_URL" "$CLONE_DIR"; then
        echo "Failed to clone repository" >&2
        exit 1
    fi
fi

# Change to repo directory and checkout branch
if ! cd "$CLONE_DIR"; then
    echo "Failed to change to repository directory" >&2
    exit 1
fi

if ! git checkout "$BRANCH"; then
    echo "Failed to checkout branch $BRANCH" >&2
    exit 1
fi

cd ..

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
    local in_array_desc=0
    local array_desc=""
    local current_param=""

    while IFS= read -r line; do
        # Check for array parameter definition
        if [[ $line =~ \*[[:space:]]*@param[[:space:]]+([^[:space:]]+)[[:space:]]+(\$[^[:space:]]+)[[:space:]]+\{(.*)$ ]]; then
            if [ $has_params -eq 0 ]; then
                output="| Parameter | Type | Description |\n|-----------|------|-------------|\n"
                has_params=1
            fi
            local type="${BASH_REMATCH[1]}"
            local var="${BASH_REMATCH[2]}"
            current_param="$var"
            in_array_desc=1
            array_desc="${BASH_REMATCH[3]}\n"
            continue
        fi

        # Standard parameter
        if [[ $line =~ \*[[:space:]]*@param[[:space:]]+([^[:space:]]+)[[:space:]]+(\$[^[:space:]]+)[[:space:]]+(.*) ]]; then
            if [ $has_params -eq 0 ]; then
                output="| Parameter | Type | Description |\n|-----------|------|-------------|\n"
                has_params=1
            fi
            local type="${BASH_REMATCH[1]}"
            local var="${BASH_REMATCH[2]}"
            local desc="${BASH_REMATCH[3]}"
            output+="| \`$var\` | \`$type\` | $desc |\n"
            continue
        fi

        # Collect array description
        if [ $in_array_desc -eq 1 ]; then
            if [[ $line =~ \*[[:space:]]*@type[[:space:]]+([^[:space:]]+)[[:space:]]+(\$[^[:space:]]+)[[:space:]]+(.*) ]]; then
                local subtype="${BASH_REMATCH[1]}"
                local subvar="${BASH_REMATCH[2]}"
                local subdesc="${BASH_REMATCH[3]}"
                array_desc+="- \`$subvar\` ($subtype): $subdesc\n"
            elif [[ $line =~ \*[[:space:]]*\}[[:space:]]*$ ]]; then
                output+="| \`$current_param\` | \`array\` | ${array_desc} |\n"
                in_array_desc=0
                array_desc=""
                current_param=""
            elif [[ $line =~ \*[[:space:]]*([^@].+) ]]; then
                array_desc+="${BASH_REMATCH[1]}\n"
            fi
        fi
    done <<< "$comment_block"

    if [ $has_params -eq 1 ]; then
        echo -e "$output"
    fi
}

# Function to extract related filters
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
    local filter_name="$1"
    local params="$2"

    if [[ -z "$params" ]]; then
        echo -e "**Usage**\n\`\`\`php\nadd_filter( '$filter_name', function( \$value ) {\n    // Your code here\n    return \$value;\n}, 10, 1);\n\`\`\`"
        return
    fi

    local param_list=""
    local param_count=0
    local first_param_name=""
    local first_param_type=""

    while IFS= read -r line; do
        if [[ $line =~ \|\s*\`(\$[^`]+)\`\s*\|\s*\`([^`]+)\` ]]; then
            local param_name="${BASH_REMATCH[1]}"
            local param_type="${BASH_REMATCH[2]}"
            
            if [ $param_count -eq 0 ]; then
                first_param_name="$param_name"
                first_param_type="$param_type"
            fi
            
            if [ $param_count -gt 0 ]; then
                param_list+=", "
            fi
            param_list+="$param_name"
            ((param_count++))
        fi
    done <<< "$params"

    # Set default return value based on first parameter type
    local return_value="\$${first_param_name#\$}"
    if [[ "$first_param_type" == "bool" ]]; then
        return_value="true"
    fi

    if [ $param_count -eq 0 ]; then
        param_list="\$value"
        return_value="\$value"
        param_count=1
    fi

    echo -e "**Usage**\n\`\`\`php\nadd_filter( '$filter_name', function( $param_list ) {\n    // Your code here\n    return $return_value;\n}, 10, $param_count);\n\`\`\`"
}

# Function to increment counter
increment_counter() {
    local counter_file="$1"
    local current=$(<"$counter_file")
    echo $((current + 1)) > "$counter_file"
}

echo "Scanning for CoCart-specific filters..."

# Process regular filters
echo "Processing regular filters..."
while IFS= read -r match; do
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
    RELATED=$(extract_related "$COMMENT_BLOCK")
    RETURN=$(echo "$COMMENT_BLOCK" | grep "@return" | head -n 1 | sed -E 's/.*@return[[:space:]]+([^*]+).*/\1/' | sed 's/^ *//;s/ *$//')

    if [[ -z "$DESCRIPTION" && -z "$SINCE" && -z "$PARAMS" ]]; then
        echo "Skipped: $FILTER_NAME (No meaningful documentation)"
        increment_counter "${TEMP_COUNTS}.skipped"
        continue
    fi

    {
        echo "## \`$FILTER_NAME\`"
        echo ""

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
            echo "- **Returns**: \`$RETURN\`"
        fi

        echo ""
        echo "$(generate_example "$FILTER_NAME" "$PARAMS")"
        echo ""

        echo "**Defined in**: [\`$RELATIVE_PATH\`]($GITHUB_LINK)"
        echo ""
        echo "---"
        echo ""
    } >> "$OUTPUT_FILE"

    increment_counter "${TEMP_COUNTS}.processed"
    echo "Processed: $FILTER_NAME"
done < <(grep -rn "apply_filters" "$CLONE_DIR" --include="*.php")

# Process deprecated filters
echo "Processing deprecated filters..."
while IFS= read -r match; do
    # Extract the line content
    LINE_CONTENT=$(echo "$match" | cut -d: -f3-)

    # Extract filter name, version, and replacement using string manipulation
    if [[ $LINE_CONTENT =~ cocart_do_deprecated_filter\([[:space:]]*[\'\"]([^\'\"]+)[\'\"][[:space:]]*,[[:space:]]*[\'\"]([^\'\"]+)[\'\"][[:space:]]*,[[:space:]]*[\'\"]([^\'\"]+)[\'\"] ]]; then
        DEPRECATED_FILTER="${BASH_REMATCH[1]}"
        VERSION="${BASH_REMATCH[2]}"
        REPLACEMENT_FILTER="${BASH_REMATCH[3]}"
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
        RELATED=$(extract_related "$COMMENT_BLOCK")
        RETURN=$(echo "$COMMENT_BLOCK" | grep "@return" | head -n 1 | sed -E 's/.*@return[[:space:]]+([^*]+).*/\1/' | sed 's/^ *//;s/ *$//')

        {
            echo "## \`$DEPRECATED_FILTER\`"
            echo ""
            echo "<Warning>**Deprecated:** This filter was deprecated in version $VERSION. Use \`$REPLACEMENT_FILTER\` instead.</Warning>"
            echo ""

            if [[ -n "$RELATED" ]]; then
                echo -e "$RELATED"
            fi

            if [[ -n "$PARAMS" ]]; then
                echo "$PARAMS"
                echo ""
            fi

            if [[ -n "$RETURN" ]]; then
                echo "- **Returns**: \`$RETURN\`"
            fi

            echo ""
            echo "**Defined in**: [\`$RELATIVE_PATH\`]($GITHUB_LINK)"
            echo ""
            echo "---"
            echo ""
        } >> "$OUTPUT_FILE"

        increment_counter "${TEMP_COUNTS}.processed"
        echo "Processed deprecated filter: $DEPRECATED_FILTER"
    fi
done < <(grep -rn "cocart_do_deprecated_filter" "$CLONE_DIR" --include="*.php")

# Read final counts
PROCESSED_COUNT=$(<"${TEMP_COUNTS}.processed")
SKIPPED_COUNT=$(<"${TEMP_COUNTS}.skipped")
TOTAL_COUNT=$((PROCESSED_COUNT + SKIPPED_COUNT))

echo "Summary:"
echo "- Processed: $PROCESSED_COUNT filters"
echo "- Skipped: $SKIPPED_COUNT filters"
echo "- Total: $TOTAL_COUNT filters"
echo "Documentation written to $OUTPUT_FILE"