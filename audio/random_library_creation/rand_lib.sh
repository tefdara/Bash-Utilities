#!/bin/bash

# This script picks random audio files from a directory and its subdirectories and creates 
# a new library with the selected files. It takes in the directory path as the first argument

# Bash shortcut -> randaulib
# You can use echo to add it to ~/.zprofile or ~/.bash_profile or ~/.bashrc, depending on your system
# echo "alias randaulib=\"bash ~/path-to-script/rand_lib.sh\"" >> ~/.zprofile && source ~/.zprofile


# Default number of files to pick from each folder
num_files_to_pick=1
max_duration=-1
folder_match="*"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -n)
      num_files_to_pick="$2"
      shift
      shift
      ;;
    -d)
      max_duration="$2"
      shift
      shift
      ;;
    -f)
      folder_match="*$2*"
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

# Check if the directory path is provided
if [ -z "$search_path_arg" ]; then
  echo "Usage: $0 directory_path [-n num_files_to_pick] [-d max_duration_in_milliseconds] [-f folder_match]"
  exit 1
fi

search_path="$search_path_arg"
home_dir="$(realpath ~)"

# Safety check: prevent the script from running in the home directory
if [ "$search_path" = "$home_dir" ]; then
  echo "Error: The script cannot be run in the home directory."
  exit 2
fi

new_folder="${search_path}/Random_Audio_Files"

# Create the new folder if it does not exist
mkdir -p "$new_folder"

# Find directories in the search path
dirs="$(find "$search_path" -type d -name "$folder_match" -not -path "$search_path" -not -path "$new_folder")"

if [[ "$dirs" == "" ]]; then
    echo "No directories found! Make sure you pass the right directory";
    exit 1
fi

# Iterate through the directories
while IFS= read -r dir; do
  # Initialize an empty array to hold audio files
  audio_files=()

  # Use a while loop to read the output of the find command into the array
  while IFS= read -r file; do
    audio_files+=("$file")
  done < <(find "$dir" -type f \( -name '*.wav' -o -name '*.aiff' -o -name '*.mp3' -o -name '*.flac' -o -name '*.m4a' -o -name '*.aac' \))

  # Check if any audio files were found
  if [[ ${#audio_files[@]} -gt 0 ]]; then
    # Filter audio files by duration if the -d argument is provided
    if [ $max_duration -ge 0 ]; then
      audio_files=($(for file in "${audio_files[@]}"; do
        duration_ms=$(mediainfo --Output="Audio;%Duration%" "$file")
        duration_ms=${duration_ms:-0}
        if [ $duration_ms -le $max_duration ]; then
          echo "$file"
        fi
      done))
    fi

    # Pick the specified number of random audio files
    for ((i=0; i<num_files_to_pick && ${#audio_files[@]} > 0; i++)); do
      random_index=$(( RANDOM % ${#audio_files[@]} ))
      random_audio_file="${audio_files[$random_index]}"

      # Copy the random audio file to the new folder
      echo "Copying ${random_audio_file} to ${new_folder}..."
      cp "${random_audio_file}" "${new_folder}"

      # Remove the selected file from the array
      unset 'audio_files[random_index]'
    done
  else
    echo "No audio files found in ${dir}"
  fi
done <<< "$dirs"
