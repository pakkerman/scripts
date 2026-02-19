#!/usr/bin/env bash
#
echo $SHELL

SCRIPT="$1"
# Function to execute the script
execute_script() {
	clear
	echo "Changes detected. Executing $SCRIPT..."
	bash "$SCRIPT"
}

# Execute the script once initially
execute_script

# Watch for changes and execute the script
while true; do
	fswatch -1 "$SCRIPT" >/dev/null
	execute_script
done
