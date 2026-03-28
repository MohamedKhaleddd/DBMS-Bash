#! /usr/bin/bash

# get the directory where this script is located
export SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# change to script directory
cd "$SCRIPT_DIR"

# enable extended globbing
shopt -s extglob

# SOURCE ALL MODULES
# 1-source configuration
source "$SCRIPT_DIR/config.sh"

# 2-source utility modules
source "$SCRIPT_DIR/utils/helpers.sh"
source "$SCRIPT_DIR/utils/validation.sh"
source "$SCRIPT_DIR/utils/display.sh"

# 3-source table operations
source "$SCRIPT_DIR/modules/table.sh"

# 4-source data operations
source "$SCRIPT_DIR/modules/insert.sh"
source "$SCRIPT_DIR/modules/select.sh"
source "$SCRIPT_DIR/modules/update.sh"
source "$SCRIPT_DIR/modules/delete.sh"

# 5-source database operations
source "$SCRIPT_DIR/modules/database.sh"
source "$SCRIPT_DIR/menus/db_menu.sh"
source "$SCRIPT_DIR/menus/main_menu.sh"

# clear screen 
clear

# display welcome message
echo ""
echo "=============================================================================="
echo "       BASH SHELL DBMS .... Made by Mohamed_El_Ftiany and Omar_Wael  "
echo "=============================================================================="
echo ""
echo "Welcome to Bash Shell Database Management System"
echo ""

# initialize database storage
init_db

# start main menu
main_menu
