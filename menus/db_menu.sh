#! /usr/bin/bash

#DATABASE MENU

database_menu() {
    while true; do
        echo ""
        print_line
        echo "      DATABASE MENU - $CURRENT_DB"
        print_line
        
        select opt in "Create Table" "List Tables" "Drop Table" "Insert" "Select" "Delete" "Update" "Disconnect"
        do
            case $REPLY in
                1)
                    create_table
                    break
                    ;;
                2)
                    list_tables
                    break
                    ;;
                3)
                    drop_table
                    break
                    ;;
                4)
                    insert_into_table
                    break
                    ;;
                5)
                    select_from_table
                    break
                    ;;
                6)
                    delete_from_table
                    break
                    ;;
                7)
                    update_table
                    break
                    ;;
                8)
                    CURRENT_DB=""
                    echo "Disconnected from database"
                    return
                    ;;
                *)
                    echo "Invalid option. Please select 1-8."
                    break
                    ;;
            esac
        done
    done
}
