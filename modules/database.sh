#! /usr/bin/bash

#                    DATABASE MODULE


#                    INITIALIZATION 




# Initialize database storage directory

init_db() {
    if [[ ! -d "$DB_ROOT" ]]; then
        mkdir -p "$DB_ROOT"
        echo "Database storage initialized at: $DB_ROOT"
    fi
}

#              --------CREATE DATABASE-----------------

create_database() {
    echo ""
    print_line
    echo "         CREATE DATABASE"
    print_line
    
    read -p "Enter database name: " db_name
    
    if is_empty "$db_name"; then
        echo "Error: Name cannot be empty"
        return 1
    fi
    
    if ! is_valid_name "$db_name"; then
        echo "Error: Invalid name. Use letters, numbers, underscore only"
        echo "       (must start with letter or underscore)"
        return 1
    fi
    
    if database_exists "$db_name"; then
        echo "Error: Database already exists"
        return 1
    fi
    
    mkdir -p "$DB_ROOT/$db_name/tables"
    mkdir -p "$DB_ROOT/$db_name/metadata"
    
    echo "name=$db_name" > "$DB_ROOT/$db_name/metadata/$INFO_FILE"
    echo "created=$(date)" >> "$DB_ROOT/$db_name/metadata/$INFO_FILE"
    
    echo "Database '$db_name' created successfully"
}

# ------------------------- LIST DATABASES ------------------------------
list_databases() {
    echo ""
    print_line
    echo "          LIST DATABASES"
    print_line
    
    if [[ ! -d "$DB_ROOT" ]] || is_dir_empty "$DB_ROOT"; then
        echo "No databases found"
        return 0
    fi
    
    echo ""
    display_databases_table
}

#   -------------------- CONNECT TO DATABASE ---------------             

connect_database() {
    echo ""
    print_line
    echo "       CONNECT TO DATABASE"
    print_line
    
    if [[ ! -d "$DB_ROOT" ]] || is_dir_empty "$DB_ROOT"; then
        echo "No databases available"
        return 1
    fi
    
    echo "Available databases:"
    ls -1 "$DB_ROOT"
    echo ""
    
    read -p "Enter database name: " db_name
    
    if ! database_exists "$db_name"; then
        echo "Error: Database does not exist"
        return 1
    fi
    
    CURRENT_DB="$db_name"
    echo "Connected to '$db_name'"
    
    database_menu
}
	
#   -------------------- DROP DATABASE --------------- 
drop_database() {
    echo ""
    print_line
    echo "           DROP DATABASE"
    print_line
    
    if [[ ! -d "$DB_ROOT" ]] || is_dir_empty "$DB_ROOT"; then
        echo "No databases available"
        return 0
    fi
    
    echo "Available databases:"
    ls -1 "$DB_ROOT"
    echo ""
    
    read -p "Enter database name to drop: " db_name
    
    if ! database_exists "$db_name"; then
        echo "Error: Database does not exist"
        return 1
    fi
    
    if confirm "Are you sure you want to drop '$db_name'?"; then
        rm -rf "$DB_ROOT/$db_name"
        echo "Database '$db_name' dropped successfully"
        
        if [[ "$CURRENT_DB" == "$db_name" ]]; then
            CURRENT_DB=""
        fi
    else
        echo "Operation cancelled"
    fi
}
