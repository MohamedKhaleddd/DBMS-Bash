# DBMS-Bash
Bash Shell Script DBMS
------------------------------------------------------------------------------------------------------------------------------------
# Project Description

This project is a Database Management System (DBMS) fully implemented using Bash scripting. The application allows users to create databases and tables, insert, update, delete, and retrieve data. All operations are performed through a Command Line Interface (CLI).
-------------------------------------------------------------------------------------------------------------------------------------
# Features

    Main Menu
        Create Database
        List Databases
        Connect to Database
        Drop Database

    Table Menu (inside a database)
        Create Table
        List Tables
        Drop Table
        Insert into Table
        Select from Table
        Delete from Table
        Update Table

# Project Structure & Implementation

    Databases are stored as directories in the script’s working directory.
    Tables are stored as files within the corresponding database directory.
    Data is stored in text files with columns separated by a delimiter (e.g., :).
    Input validation ensures correct data types for each column.
    awk is used for data processing and formatting.
    Bash functions are used for reusable operations (e.g., input validation, formatting output).
    
    
# Work split (Elftiany & Omar)

    Omar Wael
        config 
        helpers 
        database 
        main_menu 
        db_menu 
        table module 
        insert module 
        select module 


    Mohamed Elftiany
         validation
         display
         update
         delete
         main


