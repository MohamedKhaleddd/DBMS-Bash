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
    
    
