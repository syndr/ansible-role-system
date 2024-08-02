#!/bin/bash
# moon-dust.sh - Wrapper script for the provided command to log to systemd

# Initialize variables
verbose=false
use_systemd_notify=false

# Display help
show_help() {
    echo "moon-dust.sh - Wrapper script to log the the provided command to systemd"
    echo "               Command output is redirected to the systemd journal and will not be displayed on the terminal"
    echo
    echo "Usage: $0 [-v] [-n] [-t systemd-tag] <command> [command-args]"
    echo
    echo "Options:"
    echo "  -v              Enable verbose output"
    echo "  -n              Enable systemd-notify functionality"
    echo "  -t systemd-tag  Specify systemd tag for logging (defaults to 'moon-dust-<random>')"
    echo "  -h              Show this help message"
    echo
    echo "Arguments:"
    echo "  <command>       The command to run"
    echo "  [command-args]  Arguments for the command"
}

# Conditionally echo messages
verbose_echo() {
    if [ "$verbose" = true ]; then
        TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
        echo -e "$TIMESTAMP: $1"
    fi
}

# Send notifications to systemd
notify() {
    if [ "$use_systemd_notify" = true ]; then
        local message="$1"
        systemd-notify --status="$message"
    fi
}

# Set up logging messages to syslog via the file descriptor '3'
start_logging(){
    verbose_echo "Setting up logging..."

    local PIPE="/tmp/moon-dust-${unique_id}.pipe"

    # Create the named pipe
    if [[ ! -p $PIPE ]]; then
        mkfifo $PIPE
    fi

    verbose_echo "Deploying dendrite to $PIPE"

    # Set up logging to systemd using systemd-cat
    systemd-cat -t "$systemd_tag" < $PIPE &

    verbose_echo "Logging to systemd with tag: $systemd_tag"

    verbose_echo "Creating file descriptor 3"

    # Redirect file descriptor 3 to the named pipe
    exec 3> $PIPE

    # Exit nicely
    trap 'quit' SIGINT SIGTERM
}

# Clean up and exit
quit(){
    local exit_code=${1:-1}
    local PIPE="/tmp/moon-dust-${unique_id}.pipe"

    verbose_echo "Closing logging dendrite $PIPE"

    # Close logging file descriptors
    exec 3>&-
    rm -f $PIPE

    verbose_echo "Exiting with code: $exit_code"

    exit $exit_code
}


### Main ###

# Process flags and arguments
while getopts "vnt:h" opt; do
    case ${opt} in
        v)
            verbose=true
            ;;
        n)
            use_systemd_notify=true
            ;;
        t)
            systemd_tag="$OPTARG"
            ;;
        h)
            show_help
            exit 0
            ;;
        \?)
            show_help
            exit 1
            ;;
    esac
done
shift $((OPTIND -1))

# Ensure at least one argument is provided
if [ $# -lt 1 ]; then
    show_help
    exit 1
fi

if [ "$verbose" = true ]; then
    echo -e "\n 🌘 Ground up moon rocks -- it turns out they're a great portal conductor! 🌒 \n"
fi

# Command to run
command_to_run="$1"
shift
command_args="$@"

verbose_echo "🪨 Destination coordinates: $command_to_run"
verbose_echo "🪨 Destination frequency: $command_args"

# Generate a unique identifier using the process ID and a random number
unique_id="${$}-${RANDOM}"

verbose_echo "🪨 Unique identifier: $unique_id"

# Default systemd tag
if [ -z "$systemd_tag" ]; then
    systemd_tag="moon-dust-$unique_id"
fi

verbose_echo "🪨 Systemd tag: $systemd_tag"

# Set up logging
start_logging

if [ "$use_systemd_notify" = true ]; then
    # Check if systemd-notify exists
    if ! command -v systemd-notify &> /dev/null; then
        echo "ERROR: systemd-notify not found. Notify option not supported."
        quit 1
    fi
    notify "Starting $command_to_run"
fi

verbose_echo "🪞 Generating portal with command: $command_to_run $command_args"

# Action!
eval "$command_to_run $command_args" >&3 2>&3

if [ "$use_systemd_notify" = true ]; then
    notify "Finished $command_to_run"
fi

verbose_echo "Closing portal..."

quit $?

