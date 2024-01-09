#!/bin/bash

# This script runs a python script on audio files in a directory and its subdirectories to extract descriptors

# Bash shortcut -> batchpy
# you can use echo to add it to ~/.zprofile or ~/.bash_profile or ~/.bashrc, depending on your system
# echo "alias batchpy="bash ~/path-to-script/batch_py.sh\"" >> ~/.zprofile && source ~/.zprofile


# Set the options for the Python script
OPTIONS=""

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -s|--script)
    SCRIPT="$2"
    shift 
    shift 
    ;;
    -p|--path)
    ROOT_DIR="$2"
    shift
    shift 
    ;;
    -o|--options)
    OPTIONS="$2"
    shift 
    shift 
    ;;
    *)    
    shift 
    ;;
esac
done

# Find all .wav, .aif, and .aiff files in the directory and its subdirectories
find "${ROOT_DIR}" -type f \( -iname \*.wav -o -iname \*.aif -o -iname \*.aiff \) | while read -r file
do
  echo "Processing ${file}"
  # Run the script on each file with the specified options
  "${SCRIPT}" "${file}" ${OPTIONS}
done