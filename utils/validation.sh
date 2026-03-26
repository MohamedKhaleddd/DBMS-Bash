#! /usr/bin/bash


#_________________________________Validation Func_________________________________________________                            

# Func to validate names, data types, and values



#---------------------NAME VALIDATION--------------------------------------------------------                                  


# Check if name is valid (starts with letter/underscore,) 

# contains only (alphanumeric and underscore)

# --- Name Validation by Regix ------------
is_valid_name() {
    local name=$1
    # ----------------Make sure that the name is not empty or contaning spaces only by using helper-----------------
    if is_empty "$name"; then
        return 1
    fi
    # ------------------------Sure that name started with char or (_) and containing num or char only-------------
    [[ "$name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]
}

# --- DATA TYPE VALIDATION ---
validate_int() {

#-----------------Using awk to sure the numbers are (+ or -)-----------------------------------          
    echo "$1" | awk '$0 ~ /^-?[0-9]+$/ {exit 0} {exit 1}'
}

validate_float() {
    local val=$1
    [[ "$val" =~ ^-?[0-9]+\.?[0-9]*$ ]]
}

validate_date() {
    local val=$1
    [[ "$val" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]
}

validate_bool() {
    local val=$1
    case $val in
        [Tt][Rr][Uu][Ee]|[Ff][Aa][Ll][Ss][Ee]|1|0|[Yy][Ee][Ss]|[Nn][Oo]) return 0 ;;
        *) return 1 ;;
    esac
}

validate_value() {
    local val=$1
    local type=$2
    case $type in
        "integer") validate_int "$val" ;;
        "float")   validate_float "$val" ;;
        "string")  return 0 ;;
        "boolean") validate_bool "$val" ;;
        "date")    validate_date "$val" ;;
        *)         return 1 ;;
    esac
}

# --- Data type converstion ---------------------------
get_data_type() {
    local type=$1
    case $type in
        [Ii][Nn][Tt]|[Ii][Nn][Tt][Ee][Gg][Ee][Rr]) echo "integer" ;;
        [Ff][Ll][Oo][Aa][Tt]|[Dd][Oo][Uu][Bb][Ll][Ee]) echo "float" ;;
        [Ss][Tt][Rr]|[Ss][Tt][Rr][Ii][Nn][Gg]|[Tt][Ee][Xx][Tt]) echo "string" ;;
        [Bb][Oo][Oo][Ll]|[Bb][Oo][Oo][Ll][Ee][Aa][Nn]) echo "boolean" ;;
        [Dd][Aa][Tt][Ee]) echo "date" ;;
        *) echo "" ;;
    esac
}

# -------------- check if exists ---------------------------
database_exists() {
    [[ -d "$DB_ROOT/$1" ]]
}

table_exists() {
    [[ -f "$DB_ROOT/$CURRENT_DB/tables/$1.tbl" ]]
}

value_exists_in_column() {
    local table_file=$1
    local col_idx=$2
    local value=$3
    local result=$(awk -F'|' -v col=$col_idx -v val="$value" \
        'NR>1 && $col==val {print 1; exit}' "$table_file")
    [[ "$result" == "1" ]]
}
