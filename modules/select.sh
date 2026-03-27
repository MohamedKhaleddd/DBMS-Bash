#! /usr/bin/bash

# SELECT MODULE
# Functions for selecting and displaying data from tables

# SELECT FROM TABLE

select_from_table() {
    echo ""
    print_line
    echo "        SELECT FROM TABLE"
    print_line
    echo "Database: $CURRENT_DB"
    echo ""
    
    local tables_dir="$DB_ROOT/$CURRENT_DB/tables"
    
    # Check if any tables exist
    if [[ ! -d "$tables_dir" ]] || [[ -z $(ls -A "$tables_dir"/*.tbl 2>/dev/null) ]]; then
        echo "No tables available"
        return 1
    fi
    
    # Show available tables
    echo "Available tables:"
    for tbl in "$tables_dir"/*.tbl; do
        echo "  - $(basename "$tbl" .tbl)"
    done
    echo ""
    
    # Get table name
    read -p "Enter table name: " table_name
    
    # Check if table exists
    if ! table_exists "$table_name"; then
        echo "Error: Table does not exist"
        return 1
    fi
    
    local table_file=$(get_table_file "$table_name")
    
    # Get header
    local header=$(head -1 "$table_file")
    IFS='|' read -ra cols <<< "$header"
    
    echo ""
    echo "1. Select all rows"
    echo "2. Select with condition (where column = value)"
    read -p "Choose option: " opt
    
    case $opt in
        1)
            echo ""
            draw_table "$table_file"
            ;;
        2)
            select_with_condition "$table_file" "$header" "${cols[@]}"
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
}

# SELECT WITH CONDITION

select_with_condition() {
    local table_file=$1
    local header=$2
    shift 2
    local cols=("$@")
    
    echo ""
    echo "Available columns: ${cols[*]}"
    read -p "Enter column name for condition: " col_name
    read -p "Enter value to match: " col_val
    
    # Find column index
    local col_idx=-1
    for i in "${!cols[@]}"; do
        if [[ "${cols[$i]}" == "$col_name" ]]; then
            col_idx=$((i + 1))
            break
        fi
    done
    
    if [[ $col_idx -eq -1 ]]; then
        echo "Error: Column '$col_name' not found"
        return 1
    fi
    
    # Create temp file with filtered data
    local temp_file=$(mktemp)
    echo "$header" > "$temp_file"
    awk -F'|' -v col=$col_idx -v val="$col_val" \
        'NR>1 && $col==val {print}' "$table_file" >> "$temp_file"
    
    echo ""
    echo "Results for $col_name = '$col_val':"
    draw_table "$temp_file"
    rm -f "$temp_file"
}
