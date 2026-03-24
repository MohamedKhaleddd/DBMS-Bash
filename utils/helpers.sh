#! /usr/bin/bash

# --- Display Helpers ---
print_line() {
    echo "=========================================="
}

print_header() {
    local title=$1
    echo ""
    print_line
    printf "%*s\n" $(((${#title}+42)/2)) "$title"
    print_line
}

# --- Input Helpers ---
pause() {
    echo ""
    read -p "press enter to continue..." dummy
}

confirm() {
    local prompt=$1
    local response
    read -p "$prompt (y/n): " response
    case $response in
        [Yy]|[Yy][Ee][Ss]) return 0 ;;
        *) return 1 ;;
    esac
}

# --- String Helpers ---
trim() {
    echo "$1" | awk '{$1=$1; print}'
}

is_empty() {
    echo "$1" | awk -v val="$1" '{
        gsub(/^[ \t]+|[ \t]+$/, "", val); 
        if (length(val) == 0) exit 0; else exit 1;
    }'
    if [[ $? -eq 0 ]] || [[ -z "$1" ]]; then
        return 0
    else
        return 1
    fi
}

# --- File Helpers ---
count_data_rows() {
    local file=$1
    if [[ -f "$file" ]]; then
        awk 'NR > 1 { count++ } END { print count + 0 }' "$file"
    else
        echo 0
    fi
}

is_dir_empty() {
    local dir=$1
    ls -A "$dir" 2>/dev/null | awk 'BEGIN {empty=0} {empty=1; exit} END {exit empty}'
}
