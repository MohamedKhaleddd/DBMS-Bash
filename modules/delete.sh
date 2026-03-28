#! /usr/bin/bash

# DELETE MODULE
# Functions for deleting data from tables

#DELETE FROM TABLE
# (UI)
delete_from_table() {
    echo ""
    print_line
    echo "       DELETE FROM TABLE"
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
    
    # Count matching rows
    local count=$(awk -F'|' -v col=$col_idx -v val="$col_val" \
        'NR>1 && $col==val {c++} END{print c+0}' "$table_file")
    
    if [[ $count -eq 0 ]]; then
        echo "No rows found matching $col_name = '$col_val'"
        return 0
    fi
    
    # Confirm deletion
    echo ""
    echo "Found $count row(s) matching the condition"
    
    if ! confirm "Delete these rows?"; then
        echo "Operation cancelled"
        return 0
    fi
    
    # Execute delete
    local temp_file=$(mktemp)
    echo "$header" > "$temp_file"
    awk -F'|' -v col=$col_idx -v val="$col_val" \
        'NR>1 && $col!=val {print}' "$table_file" >> "$temp_file"
    mv "$temp_file" "$table_file"
    
    echo "$count row(s) deleted successfully"
}
