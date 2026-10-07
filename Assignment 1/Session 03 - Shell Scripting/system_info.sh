#!/bin/bash

# Shell Scripting Homework Task - System Information Script

echo "========================================="
echo "System Information Script"
echo "========================================="
echo ""

# 1. Print current date
echo "Current Date:"
CURRENT_DATE=$(date)
echo "$CURRENT_DATE"
echo ""

# 2. Print hostname
echo "Hostname:"
HOSTNAME_INFO=$(hostname)
echo "$HOSTNAME_INFO"
echo ""

# 3. Print username
echo "Current Username:"
CURRENT_USER=$(whoami)
echo "$CURRENT_USER"
echo ""

# 4. Print disk usage
echo "Disk Usage:"
df -h
echo ""

# 5. Print running processes
echo "Running Processes:"
ps aux
echo ""

# 6. Take user input
read -p "Enter a directory name to create: " DIR_NAME

# 7. Create a directory
mkdir -p "$DIR_NAME"
echo "Directory '$DIR_NAME' created successfully!"
echo ""

# 8. Create a file
FILE_NAME="$DIR_NAME/process_info.txt"
touch "$FILE_NAME"
echo "File '$FILE_NAME' created successfully!"
echo ""

# 9. Store running processes information in the file using > output redirection
ps aux > "$FILE_NAME"
echo "Running processes information stored in '$FILE_NAME'"
echo ""

# Display file content
echo "File Content:"
cat "$FILE_NAME" | head -10
echo "... (showing first 10 lines)"
echo ""

echo "========================================="
echo "Script Completed!"
echo "========================================="
