#!/bin/bash

# This script finds all audio files of a given format in a given folder and copies them into a new directory provided by the user.
# It takes in the format as the first argument, the source directory as the 2nd and destination directory as 3d
# The destination directory is optional and if not provided, the script will create a new directory with the format name in the source directory
# Example usage: copyaudiofiles -f .wav ~/Desktop ~/Desktop/destination
# Example usage: copyaudiofiles -f .wav ~/Desktop


# Bash shortcut -> gatherfiles
# You can use echo to add it to ~/.zprofile or ~/.bash_profile or ~/.bashrc, depending on your system
# echo "alias gathersounds=\"bash ~/path-to-script/gather_sounds\"" >> ~/.zprofile && source ~/.zprofile

usage() {
  echo "Usage: copyaudiofiles -f format source_directory_path destination_directory_path"
}

if [ -z "$1" ] || [ "$1" != "-f" ] || [ -z "$2" ] || [ -z "$3" ]; then
  usage
  exit 1
fi

format="$2"
source_path="$3"

# Safety check: prevent the script from running in the home directory
home_dir="$(realpath ~)"
if [ "$source_path" = "$home_dir" ] || [ "$destination_path" = "$home_dir" ]; then
  echo "Error: The script cannot be run in the home directory."
  exit 2
fi

# Set default destination directory if not provided and use the format as the directory name without the dot
if [ -z "$4" ]; then
  destination_path="${source_path}/Gathered Files/${format:1}"
else
  destination_path="$4"
fi

# Create destination directory if it doesn't exist
if [ ! -d "$destination_path" ]; then
  mkdir -p "$destination_path"
fi

# Read audio files into an array using a while loop
audio_files=()
while IFS= read -r -d $'\0'; do
    audio_files+=("$REPLY")
done < <(find "$source_path" -type f -iname "*$format" -print0)

if [[ ${#audio_files[@]} -eq 0 ]]; then
    echo "No audio files found! Make sure you pass the right directory and format";
    exit 1
fi

# Copy audio files to destination directory
for file in "${audio_files[@]}"; do
  filename=$(basename "$file")
  new_filepath="${destination_path}/${filename}"
  if [ "$file" != "$new_filepath" ]; then
    echo "Copying ${file} to ${new_filepath}"
    cp "$file" "$new_filepath"
  fi
done