#!/usr/bin/env bash

# Settings to control the behavior of the shell and the environment 
# Exit immediately if a command exits with a non-zero status and treat unset variables as an error.
set -eu
# This setting prevents errors in a pipeline from being masked.
set -o pipefail

readonly DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)  # Get the script's directory.
readonly SELF="${BASH_SOURCE[0]}"  # Store the script's name.
readonly BASE_SELF=$(basename "$SELF")  # Get the base name of the script.
readonly VERSION="0.0.1"  # Script version

readonly USER_ID=$(id -u)
readonly GROUP_ID=$(id -g)

readonly USER=nycto  # Define the user for the Docker container.
readonly IMAGE=ubuntu-3:v3  # To define what Docker image to use
readonly BIN=/usr/local/lib64/LispWorksPersonal/lispworks-personal-8-0-1-amd64-linux  # Path to the LispWorks binary.

# Error and warning functions
error () { echo -e "\e[0;31m\e[1mError: \e[0;0m$@" >&2; exit 1; }  # Function to handle errors.
warning () { echo -e "\e[0;33m\e[1mWarning: \e[0;0m$@" >&2; return 0; }  # Function to handle warnings.

OPT_HELP=  # Initialize help option.
OPT_DEBUG=  # Initialize debug option.
OPT_VERBOSE=  # Initialize verbose option.

mute () {
  "$@" > /dev/null 2>&1  # Run a command silently, suppressing output.
}

display_usage () {
  cat <<EOF
Usage: $BASE_SELF [OPTIONS]

Options:
-h, --help
EOF
  exit 0
}

debug () {
  if [[ -n "$OPT_DEBUG" ]]; then  # Check if debug mode is enabled.
    echo '**'
    echo "\$@: $@"
    echo "\$OPT_HELP: $OPT_HELP"
    echo "\$OPT_VERBOSE: $OPT_VERBOSE"
  fi
}

parse_arguments () {
  debug parse_arguments "$@"

  local opts
  opts=$(getopt -n "$SELF" --options hdv --longoptions help,debug,verbose -- "$@")  # Parse command-line options.

  if [[ $? != 0 ]]; then error "Failed to parse arguments."; fi  # Error handling for argument parsing.

  eval set -- "$opts"  # Set positional parameters to parsed options.

  while true; do
    case "$1" in
      (-h|--help) OPT_HELP=true; shift ;;  # Help option.
      (-d|--debug) OPT_DEBUG=true; shift ;;  # Debug option.
      (-v|--verbose) OPT_VERBOSE=true; shift ;;  # Verbose option.
      (--) shift; break ;;  # End of options.
      (*) break ;;  # Break on any other input.
    esac
  done
}

process_options () {
  debug process_options "$@"

  if [[ -n "$OPT_HELP" ]]; then  # Check if help is requested.
    display_usage  # Display usage information.
    return 0
  fi
}

run_lispworks () {
  debug run_lispworks "$@"

  # Docker run with specified options and execute the LW path binary.
  if ! docker run -it --name nycto-ubuntu --rm \
         --user "$USER_ID:$GROUP_ID" -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
         --net=host -v $HOME:/home/nycto $IMAGE \
         bash -c "$BIN"; then
    error "Failed to execute Docker container."  # Error handling for Docker execution.
  fi
}

main () {
  debug main "$@"
  parse_arguments "$@"  # Parse command-line arguments.
  process_options "$@"  # Process options based on parsed arguments.
  run_lispworks "$@"  # Run the LispWorks application.
}

main "$@"  # Call the main function with all provided arguments.
