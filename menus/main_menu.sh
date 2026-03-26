#! /usr/bin/bash

# Main Menu
main_menu() {
    while true; do
        echo ""
        print_line
        echo "            MAIN MENU"
        print_line
        
        select opt in "Create Database" "List Databases" "Connect" "Drop Database" "Exit"
        do
            case $REPLY in
                1)
                    create_database
                    break
                    ;;
                2)
                    list_databases
                    break
                    ;;
                3)
                    connect_database
                    break
                    ;;
                4)
                    drop_database
                    break
                    ;;
                5)
                    echo ""
                    echo "Thank you for using Bash Shell DBMS ..... Made By Omar_Wael and Mohammed Al Fetiany"
                    echo "Goodbye!"
                    exit 0
                    ;;
                *)
                    echo "Invalid option. Please select 1-5."
                    break
                    ;;
            esac
        done
    done
}
