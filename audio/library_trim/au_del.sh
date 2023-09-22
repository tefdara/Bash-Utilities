#!/bin/bash

# This script finds all audio files in a given folder and deletes them if they are shorter than a given threshold

# Bash shortcut -> audel
# You can use echo to add it to ~/.zprofile or ~/.bash_profile or ~/.bashrc, depending on your system
# echo "alias audel=\"bash ~/path-to-script/auau_del.sh\"" >> ~/.zprofile && source ~/.zprofile

# Default search path and threshold values
search_path="$(pwd)"
threshold=100

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -t|--threshold)
      threshold="$2"
      shift
      shift
      ;;
    *)
      if [ -z "$search_path_arg" ]; then
        search_path_arg="$1"
      else
        echo "Error: Invalid argument '$1'"
        exit 1
      fi
      shift
      ;;
  esac
done

# Set the search path to the provided path or use the current directory if not provided
search_path="${search_path_arg:-$search_path}"

home_dir="$(realpath ~)"

# Safety check: prevent the script from running in the home directory
if [ "$search_path" = "$home_dir" ]; then
  echo "Error: The script cannot be run in the home directory."
  exit 2
fi

files="$(find "$search_path" -type f -name \*.wav)";
if [[ "$files" == "" ]]; then
    echo "No files found! Make sure you pass the right directory";
    exit 1
fi
echo "$files" | while read file; do 
    if [[ $(mediainfo --Output='Audio;%Duration%' "${file}") -lt "threshold" ]]
    then
        echo "Removing $file from the system..."
        rm "$file"
    fi 
done

