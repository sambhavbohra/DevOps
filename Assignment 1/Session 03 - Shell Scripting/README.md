# Shell Scripting Homework Task - System Information Script

## Commands Used

| Command | Purpose |
|---------|---------|
| `mkdir` | Creates directory |
| `touch` | Creates empty file |
| `echo` | Prints text |
| `df` | Shows disk usage |
| `ps` | Lists running processes |
| `read -p` | Takes user input |
| `Variables` | Stores data (CURRENT_DATE, HOSTNAME_INFO, CURRENT_USER, etc.) |
| `>` | Redirects output to file |

## How to Run

### 1. Make the script executable
```bash
chmod +x system_info.sh
```

### 2. Run the script
```bash
./system_info.sh
```

### 3. When prompted, enter a directory name
```
Enter a directory name to create: my_system_info
```

## Script Output Example

```
=========================================
System Information Script
=========================================

Current Date:
Tue Sep 01 23:45:30 PDT 2026

Hostname:
SammyBohras-Mac

Current Username:
sammybohra

Disk Usage:
Filesystem      Size  Used Avail Use% Mounted on
/dev/disk1s1   500G  250G  250G  50% /

Running Processes:
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
...

Directory 'my_system_info' created successfully!

File 'my_system_info/process_info.txt' created successfully!

Running processes information stored in 'my_system_info/process_info.txt'

File Content:
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
... (showing first 10 lines)

=========================================
Script Completed!
=========================================
```

## Key Learning Points

1. **Variables**: Store command outputs in variables using `$(command)`
2. **User Input**: Accept user input with `read -p "prompt" variable_name`
3. **Output Redirection**: Use `>` to save output to file (overwrites) and `>>` to append
4. **File Operations**: Create directories and files dynamically based on user input
5. **Command Execution**: Use backticks or `$()` to execute commands and store results

