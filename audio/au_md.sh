#!/bin/bash

# This script adds metadata to all audio files in a given directory.

# Bash shortcut -> aumd
# You can use echo to add it to ~/.zprofile or ~/.bash_profile or ~/.bashrc, depending on your system
# echo "alias aumd=\"bash ~/path-to-script/audio_metadata.sh\"" >> ~/.zprofile && source ~/.zprofile

usage() {
  echo "Usage: aumd [-c comment] path"
  echo
  echo "Example usage : aumd /audioFolder"
  echo "path: Directory path of the audio files."
  echo "-c: Optional comment to add to the metadata string. Can be used multiple times to add multiple comments."
}

if [ -z "$1" ]; then
  usage
  exit 1
fi

search_path=""
custom_comments=()

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -c)
      custom_comments+=("$2")
      shift
      shift
      ;;
    *)
      search_path="$1"
      shift
      ;;
  esac
done

# Define the file extensions to search for
file_extensions=("wav" "aif" "aiff" "flac" "mp3" "m4a" "aac")

# Safety check: prevent the script from running in the home directory
home_dir="$(realpath ~)"
search_path="$(realpath "$search_path")"
if [ "$search_path" = "$home_dir" ]; then
  echo "Error: The script cannot be run in the home directory."
  exit 2
fi

# Find all audio files in the directory and its subdirectories
audio_files=()
for extension in "${file_extensions[@]}"; do
  while IFS=  read -r -d $'\0'; do
      audio_files+=("$REPLY")
  done < <(find "$search_path" -type f -name "*.$extension" -print0)
done

if [[ ${#audio_files[@]} -eq 0 ]]; then
    echo "No audio files found! Make sure you pass the right directory and format"
    exit 1
fi

counter=1
for file in "${audio_files[@]}"; do
  filename=$(basename "$file")
  
  # Extract audio file details using ffprobe
  sample_rate=$(ffprobe -v error -select_streams a:0 -show_entries stream=sample_rate -of default=noprint_wrappers=1:nokey=1 "$file")
  bit_rate=$(ffprobe -v error -select_streams a:0 -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 "$file")
  duration=$(ffprobe -v error -select_streams a:0 -show_entries stream=duration -of default=noprint_wrappers=1:nokey=1 "$file")
  
  # Construct metadata string
  metadata_string="title=Filename: $filename\nartist=Sample rate: $sample_rate, Bit rate: $bit_rate, Duration: $duration"

  # Append custom comments to metadata string
  for comment in "${custom_comments[@]}"; do
    metadata_string="$metadata_string\ncomment=$comment"
  done
  
  temp_filepath="${search_path}/temp_${counter}.${file##*.}"
  echo "Adding comments to ${file}..."

  # Extract the filename before the first _
  source_file=$(echo "$filename" | cut -d'_' -f1)

  comments_string="Source Recording : $source_file
                        Sample Rate : $sample_rate  
                        Bit Rate : $bit_rate
                        Duration : $duration
                        "
  
  # add a number of spaces to the beginning of each line
  comments_string=$(echo "$comments_string" | sed 's/^/                        /')
  if [ ${#custom_comments[@]} -gt 0 ]; then
    comments_string="$comments_string"
    for comment in "${custom_comments[@]}"; do
      comments_string="$comments_string 
      $comment"
    done
  fi

  # Add metadata using ffmpeg
    ffmpeg -i "$file" -c copy \
    -map_metadata 0 \
    -metadata comment="$comments_string" \
                        "$temp_filepath"
  
  if [ $? -ne 0 ]; then
    echo "Error processing file: ${file}"
    continue
  fi
  
  # Remove the original file and rename the file with metadata
  rm "$file"
  mv "$temp_filepath" "${search_path}/${filename}"
  
  # Increment the counter
  counter=$((counter + 1))
done