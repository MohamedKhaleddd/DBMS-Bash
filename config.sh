#! /usr/bin/bash

# this file contains all the global variables and constants

# root directory for all databases
DB_ROOT="./databases"

# currently connected database name
CURRENT_DB=""

# table file extension
TABLE_EXT=".tbl"

# metadata file extension
META_EXT=".meta"

# info file name
INFO_FILE="info.db"

# supported data types
VALID_TYPES=("integer" "float" "string" "boolean" "date")

# path functions

# get the full path
get_db_path() {
    local db_name=$1
    echo "$DB_ROOT/$db_name"
}

# get the tables directory path
get_tables_path() {
    local db_name=$1
    echo "$DB_ROOT/$db_name/tables"
}

# get the metadata directory path
get_meta_path() {
    local db_name=$1
    echo "$DB_ROOT/$db_name/metadata"
}

# get the table file path
get_table_file() {
    local table_name=$1
    echo "$DB_ROOT/$CURRENT_DB/tables/$table_name$TABLE_EXT"
}

# Get the metadata file path for a table
get_meta_file() {
    local table_name=$1
    echo "$DB_ROOT/$CURRENT_DB/metadata/$table_name$META_EXT"
}

