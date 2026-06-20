#!/bin/sh
# Log Rotation Script
# Description:
#   This script truncates specified log files to zero bytes at a fixed interval.
#   Useful to prevent logs like syslog or auth.log from growing indefinitely.

# List of log files to truncate
FILES_TO_CLEAR="
/var/log/syslog
/var/log/auth.log
/var/log/kern.log
";

# Time interval in seconds
INTERVAL=300;  # e.g., every 300 seconds (5 minutes)

echo "Logs Rotation task began with logs rotation interval of $((INTERVAL/60)) minutes.";

# Function: truncate_file
# Purpose: Truncate a single log file safely
truncate_file() {
    FILE="$1";
    if [ -f "$FILE" ]; then
        : > "$FILE";  # truncate file to zero bytes
        echo "Cleared: $FILE";
    else
        echo "File not found: $FILE";
    fi;
}

# Infinite loop to perform log truncation at the specified interval
while true; do
    for FILE in $FILES_TO_CLEAR; do
        truncate_file "$FILE";
    done;
    sleep "$INTERVAL";
done;

