#! /usr/bin/bash

# UPDATE MODULE


# Functions for updating data in tables
update_table() {
    echo ""
    print_line
    echo "          UPDATE TABLE"
    print_line
    echo "Database: $CURRENT_DB"
    echo ""
    
    local tables_dir="$DB_ROOT/$CURRENT_DB/tables"
    
    # check if any tables exist
    if [[ ! -d "$tables_dir" ]] || [[ -z $(ls -A "$tables_dir"/*.tbl 2>/dev/null) ]]; then
        echo "No tables available"
        return 1
    fi
    
    # show available tables
    echo "Available tables:"
    for tbl in "$tables_dir"/*.tbl; do
        echo "  - $(basename "$tbl" .tbl)"
    done
    echo ""
    
    # get table name
    read -p "Enter table name: " table_name
    
    # check if table exists
    if ! table_exists "$table_name"; then
        echo "Error: Table does not exist"
        return 1
    fi
    
    local table_file=$(get_table_file "$table_name")
    local meta_file=$(get_meta_file "$table_name")
    
    # get header and primary key
    local header=$(head -1 "$table_file")
    IFS='|' read -ra cols <<< "$header"
    local pk=$(grep "^pk=" "$meta_file" | cut -d'=' -f2)
    
    echo ""
    echo "Available columns: ${cols[*]}"
    echo "Primary Key: $pk"
    echo ""
    
    # get WHERE condition
    echo "--- WHERE Condition ---"
    read -p "Column name: " cond_col
    read -p "Equals value: " cond_val
    
    # find condition column index
    local cond_idx=-1
    for i in "${!cols[@]}"; do
        if [[ "${cols[$i]}" == "$cond_col" ]]; then
            cond_idx=$((i + 1))
            break
        fi
    done
    
    if [[ $cond_idx -eq -1 ]]; then
        echo "Error: Column '$cond_col' not found"
        return 1
    fi
    
    # get SET value
    echo ""
    echo "--- SET Value ---"
    read -p "Column to update: " set_col
    read -p "New value: " set_val
    
    # find set column index
    local set_idx=-1
    for i in "${!cols[@]}"; do
        if [[ "${cols[$i]}" == "$set_col" ]]; then
            set_idx=$((i + 1))
            break
        fi
    done
    
    if [[ $set_idx -eq -1 ]]; then
        echo "Error: Column '$set_col' not found"
        return 1
    fi
    
    # get column type for validation
    local col_type=""
    while IFS= read -r line; do
        if [[ $line =~ ^${set_col}:(.+)$ ]]; then
            col_type=${BASH_REMATCH[1]}
            break
        fi
    done < <(tail -n +3 "$meta_file")
    
    # validate the new value
    if ! validate_value "$set_val" "$col_type"; then
        echo "Error: Invalid $col_type value for column '$set_col'"
        return 1
    fi
    
    # check primary key uniqueness if updating PK
    if [[ "$set_col" == "$pk" ]]; then
        local exists=$(awk -F'|' -v set_col=$set_idx -v new_val="$set_val" \
            -v cond_col=$cond_idx -v cond_val="$cond_val" \
            'NR>1 && $set_col==new_val && $cond_col!=cond_val {print 1; exit}' "$table_file")
        
        if [[ "$exists" == "1" ]]; then
            echo "Error: Primary key value '$set_val' already exists in another row"
            return 1
        fi
    fi
    
    # count matching rows
    local count=$(awk -F'|' -v col=$cond_idx -v val="$cond_val" \
        'NR>1 && $col==val {c++} END{print c+0}' "$table_file")
    
    if [[ $count -eq 0 ]]; then
        echo "No rows found matching the condition"
        return 0
    fi
    
    # Confirm update
    echo ""
    echo "Found $count row(s) to update"
    echo "SET $set_col = '$set_val' WHERE $cond_col = '$cond_val'"
    
    if ! confirm "Proceed with update?"; then
        echo "Operation cancelled"
        return 0
    fi
    
    # Execute update 
    local temp_file=$(mktemp)
    echo "$header" > "$temp_file"
    
    awk -F'|' -v cond_col=$cond_idx -v cond_val="$cond_val" \
        -v set_col=$set_idx -v set_val="$set_val" \
        'BEGIN{OFS="|"} 
         NR>1 {
             if ($cond_col==cond_val) {
                 $set_col=set_val
             }
             print
         }' "$table_file" >> "$temp_file"
    
    mv "$temp_file" "$table_file"

echo "$count row(s) updated successfully"
}
