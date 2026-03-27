#! /usr/bin/bash

#                    INSERT MODULE
# Functions for inserting data into tables
# INSERT INTO TABLE

insert_into_table() {
    echo ""
    print_line
    echo "        INSERT INTO TABLE"
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
    local meta_file=$(get_meta_file "$table_name")
    
    # Read metadata
    local pk=$(grep "^pk=" "$meta_file" | cut -d'=' -f2)
    
    # Read column definitions
    declare -a col_names
    declare -a col_types
    
    local idx=0
    while IFS= read -r line; do
        if [[ $line =~ ^(.+):(.+)$ ]]; then
            col_names[$idx]=${BASH_REMATCH[1]}
            col_types[$idx]=${BASH_REMATCH[2]}
            ((idx++))
        fi
    done < <(tail -n +3 "$meta_file")
    
    echo ""
    echo "Table: $table_name"
    echo "Primary Key: $pk"
    echo "Columns: ${#col_names[@]}"
    echo ""
    
    # Get values for each column
    declare -a values
    
    for i in "${!col_names[@]}"; do
        while true; do
            read -p "Enter ${col_names[$i]} (${col_types[$i]}): " val
            
            # Validate data type
            if validate_value "$val" "${col_types[$i]}"; then
                # Check primary key uniqueness
                if [[ "${col_names[$i]}" == "$pk" ]]; then
                    local col_num=$((i + 1))
                    if value_exists_in_column "$table_file" $col_num "$val"; then
                        echo "Error: Primary key value '$val' already exists in table"
                        continue
                    fi
                fi
                values+=("$val")
                break
            else
                echo "Error: Invalid ${col_types[$i]} value. Please try again."
            fi
        done
    done
    
    # Insert the row
    local row=$(IFS='|'; echo "${values[*]}")
    echo "$row" >> "$table_file"
    
    echo ""
    echo "Row inserted successfully!"
}
