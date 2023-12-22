#!/bin/bash

# Default configuration values
CONFIG_FILE="process_monitor.conf"
UPDATE_INTERVAL=5
CPU_ALERT_THRESHOLD=1
MEMORY_ALERT_THRESHOLD=80

logfile="process_monitor.log" # Log file path

# Function to log messages
log_activity() {
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $1" >>"$logfile"
}

# Function to load configuration from file
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        log_activity "Configuration loaded from $CONFIG_FILE"
    else
        log_activity "Configuration file $CONFIG_FILE not found. Using default configuration values."
    fi
}

# Function to save configuration to file
save_config() {
    echo "# Configuration file for Process Monitor" >"$CONFIG_FILE"
    echo "" >>"$CONFIG_FILE"
    echo "# Update interval in seconds" >>"$CONFIG_FILE"
    echo "UPDATE_INTERVAL=$UPDATE_INTERVAL" >>"$CONFIG_FILE"
    echo "" >>"$CONFIG_FILE"
    echo "# CPU usage threshold for alerts (percentage)" >>"$CONFIG_FILE"
    echo "CPU_ALERT_THRESHOLD=$CPU_ALERT_THRESHOLD" >>"$CONFIG_FILE"
    echo "" >>"$CONFIG_FILE"
    echo "# Memory usage threshold for alerts (percentage)" >>"$CONFIG_FILE"
    echo "MEMORY_ALERT_THRESHOLD=$MEMORY_ALERT_THRESHOLD" >>"$CONFIG_FILE"
    log_activity "Configuration saved to $CONFIG_FILE"
}

# Function to display the menu
display_menu() {
    clear
    echo "------ MENU ------"
    echo "1. Monitor processes"
    echo "2. Kill a process"
    echo "3. Process Statistics"
    echo "4. Search processes"
    echo "5. Process Information"
    echo "6. Configure"
    echo "7. Exit"
    echo "--------------------"
}

# Function to configure settings
configure_settings() {
    clear
    echo "------ CONFIGURATION SETTINGS ------"
    echo "1. Update interval"
    echo "2. CPU alert threshold"
    echo "3. Memory alert threshold"
    echo "4. Save configuration"
    echo "5. Back"
    echo "-------------------------------------"

    while true; do
        read -p "Enter your choice for setting: " choice
        case $choice in
        1)
            read -p "Enter the update interval in seconds: " UPDATE_INTERVAL
            ;;
        2)
            read -p "Enter the CPU alert threshold (percentage): " CPU_ALERT_THRESHOLD
            ;;
        3)
            read -p "Enter the memory alert threshold (percentage): " MEMORY_ALERT_THRESHOLD
            ;;
        4)
            save_config
            echo -e "\e[32m-------Saving successfully!-------\e[0m"
            ;;
        5)
            break
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
        esac
    done
}

# Function to monitor processes
monitor_processes() {
    clear

    while true; do
        # Get the latest process information
        #ps aux --sort=-%cpu // all processes
        processes=$(ps aux --sort=-%cpu | head -n 10)

        # Check for resource usage thresholds
        # Modify the conditions as per your requirements
        high_cpu_processes=$(echo "$processes" | awk -v threshold=$CPU_ALERT_THRESHOLD '$3 > threshold { print $0 }')
        high_mem_processes=$(echo "$processes" | awk -v threshold=$MEMORY_ALERT_THRESHOLD '$4 > threshold { print $0 }')

        # Display the latest process information
        clear
        echo "------ PROCESSES ------"
        echo "$processes"
        echo "------------------------"

        # Display alerts if thresholds exceeded
        if [ ! -z "$high_cpu_processes" ]; then
            echo -e "\e[31m⚠️ High CPU usage alert! Processes:\e[0m"
            echo "$high_cpu_processes"
            echo -e "\e[31m----------------------------\e[0m"
            log_activity "High CPU usage alert!"
            log_activity "$high_cpu_processes"
        fi

        if [ ! -z "$high_mem_processes" ]; then
            echo -e "\e[31m⚠️ High memory usage alert! Processes:\e[0m"
            echo "$high_mem_processes"
            echo -e "\e[31m----------------------------\e[0m"
            log_activity "High memory usage alert!"
            log_activity "$high_mem_processes"
        fi

        echo -e "\e[33mMonitoring processes (Press any key to stop)...\e[0m"

        ############## return to the main page ################
        read -t 1 -n 1 input # Read input with 1-second timeout
        if [ ! -z "$input" ]; then
            break
        fi
        ##############################################
        
        #echo "Testing"

        sleep "$UPDATE_INTERVAL" # Interval between updates
    done
}

# Function to kill a process
kill_process() {
    clear
    echo "Enter the Process ID to kill:"
    read pid
    kill  "$pid"
    echo "Process killed successfully!"
    log_activity "Process killed - PID: $pid"
    sleep 2
}

# Function to search processes
search_processes() {
    clear
    echo "Enter the search keyword:"
    read keyword
    processes=$(ps aux | grep "$keyword")
    echo "------ SEARCH RESULTS ------"
    echo "$processes"
    echo "----------------------------"
    log_activity "Search processes: '$keyword'"
    log_activity "$processes"
    read -p "Press Enter to continue..."
}


# Function to display process information
get_process_information() {
    clear
    echo "Enter the Process ID:"
    read pid
    process_info=$(ps -p $pid u)
    echo "------ PROCESS INFORMATION ------"
    echo "$process_info"
    echo "----------------------------------"
    log_activity "Process information for PID: $pid"
    log_activity "$process_info"
    read -p "Press Enter to continue..."
}
system_stats() {
  top -n 1
    clear
    echo "Enter the Process ID:"
    process_info=$(top -n 1)
    echo "------Process Statistics ------"
    echo "$process_info"
    echo "----------------------------------"
    read -p "Press Enter to continue..."
}
# Main script
load_config

while true; do
    display_menu

    read -p "Enter your choice: " choice
    case $choice in
    1)
        monitor_processes
        ;;
    2)
        kill_process
        ;;
    3)
        system_stats
        ;;
    4)
        search_processes
        ;;
     5)
        get_process_information
        ;;
    6)
        configure_settings
        ;;
    7)
        echo "------------Goodbye!------------"
        log_activity "Script exited"
        exit 0
        ;;
    *)
        echo "Invalid choice. Please try again."
        sleep 2
        ;;
    esac
done