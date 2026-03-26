#! /usr/bin/bash

# ------------------------------TABLE MODULE ----------------------------------
# Functions for table operations: Create, List, Drop



# ------------------------------CREATE TABLE----------------------------------

create_table() {
    echo ""
    print_line
    echo "          CREATE TABLE"
    print_line
    echo "Database: $CURRENT_DB"
    echo ""
    
    read -p "Enter table name: " table_name
   
    if is_empty "$table_name"; then
        echo "Error: Name cannot be empty"
        return 1
    fi
    
    if ! is_valid_name "$table_name"; then
        echo "Error: Invalid name. Use letters, numbers, underscore only"
        return 1
    fi
    
    if table_exists "$table_name"; then
        echo "Error: Table already exists"
        return 1
    fi
    
    read -p "Enter number of columns: " num_cols
    
    if ! validate_int "$num_cols" || [[ $num_cols -lt 1 ]]; then
        echo "Error: Invalid number. Must be a positive integer"
        return 1
    fi
    
    declare -a col_names
    declare -a col_types
    
    echo ""
    echo "Available types: integer, float, string, boolean, date"
    echo ""
    
    for ((i=1; i<=num_cols; i++)); do
        echo "--- Column $i ---"
        
        while true; do
            read -p "  Name: " col_name
            
            if is_empty "$col_name"; then
                echo "Error: Name cannot be empty"
                continue
            fi
            
            if is_valid_name "$col_name"; then
                local duplicate=0
                for existing in "${col_names[@]}"; do
                    if [[ "$existing" == "$col_name" ]]; then
                        duplicate=1
                        break
                    fi
                done
                
                if [[ $duplicate -eq 1 ]]; then
                    echo "Error: Column '$col_name' already exists"
                    continue
                fi
                break
            else
                echo "Error: Invalid name"
            fi
        done
        
        while true; do
            read -p "  Type: " col_type
            col_type=$(get_data_type "$col_type")
            
            if [[ -n "$col_type" ]]; then
                break
            else
                echo "Error: Invalid type. Use: integer, float, string, boolean, date"
            fi
        done
        
        col_names+=("$col_name")
        col_types+=("$col_type")
    done
    
    echo ""
    echo "Columns defined: ${col_names[*]}"
    echo ""
    
    while true; do
        read -p "Enter primary key column name: " pk
        
        local pk_found=0
        for col in "${col_names[@]}"; do
            if [[ "$col" == "$pk" ]]; then
                pk_found=1
                break
            fi
        done
        
        if [[ $pk_found -eq 1 ]]; then
            break
        else
            echo "Error: Column '$pk' not found in table"
        fi
    done
    
    local meta_file=$(get_meta_file "$table_name")
    echo "pk=$pk" > "$meta_file"
    echo "cols=${#col_names[@]}" >> "$meta_file"
    
    for i in "${!col_names[@]}"; do
        echo "${col_names[$i]}:${col_types[$i]}" >> "$meta_file"
    done
    
    local table_file=$(get_table_file "$table_name")
    local header=$(IFS='|'; echo "${col_names[*]}")
    echo "$header" > "$table_file"
    
    echo ""
    echo "Table '$table_name' created successfully with $num_cols columns"
    echo "Primary key: $pk"
}

#   -------------------------------LIST TABLES ---------------------------------------------

list_tables() {
    echo ""
    print_line
    echo "          LIST TABLES"
    print_line
    echo "Database: $CURRENT_DB"
    echo ""
    
    local tables_dir="$DB_ROOT/$CURRENT_DB/tables"
    
    # Check if any tables exist
    if [[ ! -d "$tables_dir" ]] || [[ -z $(ls -A "$tables_dir"/*.tbl 2>/dev/null) ]]; then
        echo "No tables found in database '$CURRENT_DB'"
        return 0
    fi
    
    display_tables_table
}

#   --------------------------DROP TABLE --------------------------

drop_table() {
    echo ""
    print_line
    echo "          DROP TABLE"
    print_line
    echo "Database: $CURRENT_DB"
    echo ""
    
    local tables_dir="$DB_ROOT/$CURRENT_DB/tables"
    
    # Check if any tables exist
    if [[ ! -d "$tables_dir" ]] || [[ -z $(ls -A "$tables_dir"/*.tbl 2>/dev/null) ]]; then
        echo "No tables available"
        return 0
    fi
    
    # Show available tables
    echo "Available tables:"
    for tbl in "$tables_dir"/*.tbl; do
        echo "  - $(basename "$tbl" .tbl)"
    done
    echo ""
    
    read -p "Enter table name: " table_name
    
    # Check if table exists
    if ! table_exists "$table_name"; then
        echo "Error: Table does not exist"
        return 1
    fi
    
    # Confirm deletion
    if confirm "Are you sure you want to drop '$table_name'?"; then
        rm -f "$(get_table_file "$table_name")"
        rm -f "$(get_meta_file "$table_name")"
        echo "Table '$table_name' dropped successfully"
    else
        echo "Operation cancelled"
    fi
}
