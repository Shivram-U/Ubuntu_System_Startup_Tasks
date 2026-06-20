import time
import os

# List of files to truncate
files_to_clear = [
    "/var/log/syslog",     # syslog file
    "/var/log/auth.log"  # add any other file here
]

# Time interval in seconds
interval = 300  # e.g., every 60 seconds

def truncate_file(file_path):
    """Truncate the file to zero bytes."""
    try:
        with open(file_path, 'w') as f:
            f.truncate(0)
        print(f"Cleared: {file_path}")
    except Exception as e:
        print(f"Error clearing {file_path}: {e}")

def main():
    while True:
        for file_path in files_to_clear:
            truncate_file(file_path)
        time.sleep(interval)

if __name__ == "__main__":
    main()

