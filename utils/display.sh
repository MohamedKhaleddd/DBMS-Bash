#! /usr/bin/bash


#------------------------Display Fun-------------------------------

# Func for formatting and displaying data in tables

# --------Table Drawing ----------------------------------------


# Draw a formatted table from a file
draw_table() {
    local file=$1
    if [[ ! -f "$file" ]] || [[ ! -s "$file" ]]; then
        echo "No data to display"
        return 1
    fi

    local header=$(head -1 "$file")
    
    # ---------------------Counting rows-------------------
    local data_count=$(count_data_rows "$file")

    if [[ "$data_count" -eq 0 ]]; then
        _draw_empty_table "$header"
        return 0
    fi

    # --------Calc The width of columns----------------
    IFS='|' read -ra cols <<< "$header"
    local widths=()
    for i in "${!cols[@]}"; do widths[$i]=${#cols[$i]}; done

    while IFS='|' read -ra row; do
        for i in "${!row[@]}"; do
            [[ ${#row[$i]} -gt ${widths[$i]} ]] && widths[$i]=${#row[$i]}
        done
    done < <(tail -n +2 "$file")

    # -----------------------Drawing Table------------------------------------------
    _print_table_separator "${widths[@]}"
    _print_table_header "$header" "${widths[@]}"
    _print_table_separator "${widths[@]}"
    _print_table_rows "$file" "${widths[@]}"
    _print_table_separator "${widths[@]}"
}

_draw_empty_table() {
    local header=$1
    IFS='|' read -ra cols <<< "$header"
    local widths=()
    for i in "${!cols[@]}"; do widths[$i]=${#cols[$i]}; done
    _print_table_separator "${widths[@]}"
    _print_table_header "$header" "${widths[@]}"
    _print_table_separator "${widths[@]}"
    echo "| (empty table) |"
}

_print_table_separator() {
    local widths=("$@")
    local sep="+"
    for w in "${widths[@]}"; do sep+=$(printf '%*s' $((w+2)) | tr ' ' '-')+; done
    echo "$sep"
}

_print_table_header() {
    local header=$1; shift; local widths=("$@")
    IFS='|' read -ra cols <<< "$header"
    local h="|"
    for i in "${!cols[@]}"; do h+=" $(printf "%-${widths[$i]}s" "${cols[$i]}") |"; done
    echo "$h"
}

_print_table_rows() {
    local file=$1; shift; local widths=("$@")
    while IFS='|' read -ra row; do
        local line="|"
        for i in "${!row[@]}"; do line+=" $(printf "%-${widths[$i]}s" "${row[$i]}") |"; done
        echo "$line"
    done < <(tail -n +2 "$file")
}

# -------------------- ls Display---------------------
display_databases_table() {
    printf "%-20s %-10s %-25s\n" "Database" "Tables" "Created"
    echo "------------------------------------------------------------"
    for db_dir in "$DB_ROOT"/*/; do
        if [[ -d "$db_dir" ]]; then
            local name=$(basename "$db_dir")
            local count=$(ls "$db_dir/tables"/*.tbl 2>/dev/null | wc -l)
            local created=$(grep "^created=" "$db_dir/metadata/info.db" 2>/dev/null | cut -d'=' -f2-)
            printf "%-20s %-10s %-25s\n" "$name" "$count" "$created"
        fi
    done
}

display_tables_table() {
    local tables_dir="$DB_ROOT/$CURRENT_DB/tables"
    printf "%-20s %-10s %-10s %-15s\n" "Table" "Columns" "Rows" "Primary Key"
    echo "------------------------------------------------------------"
    if [ -n "$(ls -A "$tables_dir"/*.tbl 2>/dev/null)" ]; then
        for tbl in "$tables_dir"/*.tbl; do
            local name=$(basename "$tbl" .tbl)
            local meta="$DB_ROOT/$CURRENT_DB/metadata/$name.meta"
            local rows=$(count_data_rows "$tbl")
            local cols=$(grep "^cols=" "$meta" 2>/dev/null | cut -d'=' -f2)
            local pk=$(grep "^pk=" "$meta" 2>/dev/null | cut -d'=' -f2)
            printf "%-20s %-10s %-10s %-15s\n" "$name" "$cols" "$rows" "$pk"
        done
    else
        echo "No tables found in this database."
    fi
}
