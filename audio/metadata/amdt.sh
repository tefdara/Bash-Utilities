#!/bin/bash

# This script adds metadata to all audio files in a given directory.
# Dependencies: ffmpeg, ffprobe, mediainfo (link : https://mediaarea.net/en/MediaInfo)
# Bash shortcut -> umd
# You can use echo to add it to ~/.zprofile or ~/.bash_profile or ~/.bashrc, depending on your system
# echo "alias aumd=\"bash ~/path-to-script/audio_metadata.sh\"" >> ~/.zprofile && source ~/.zprofile

usage() {
  echo "Usage: aumd [-c comment] path"
  echo
  echo "Example usage : amd /audioFolder -c \"This is a comment\""
  echo "path: Directory path of the audio files."
  echo "-i: Specify a single file to process."
  echo "-c: Optional comment to add to the metadata string. Can be used multiple times to add multiple comments."
  echo "-d: Log the current comments in the metadata string."
  echo "-s: Show all the streams in the file."
  echo "-dd: Disable default comments; source_file_name, source_sample_rate, source_bit_depth, source_channels, source_creation_date"
}

if [ -z "$1" ]; then
  usage
  exit 1
fi

search_path=""
custom_comments=()
log_comments=0
show_streams=0
disable_default_comments=0
input_file=""

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -c)
      custom_comments+=("$2")
      shift
      shift
      ;;
    -d)
      log_comments=1
      shift
      ;;
    -s)
      show_streams=1
      shift
      ;;
    -i)
      input_file="$2"
      shift
      ;;
    -dd)
      disable_default_comments=1
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

# if input file is specified at the same time as search path, exit
if [ -n "$input_file" ] && [ -n "$search_path" ]; then
  echo "Error: You cannot specify both an input file and a search path."
  exit 3
fi

# Find all audio files in the directory and its subdirectories
audio_files=()
for extension in "${file_extensions[@]}"; do
  # if only a single file is specified, add it to the array
  if [ -n "$input_file" ]; then
    audio_files+=("$input_file")
    break
  fi
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
  echo "Extracting audio file details for ${file}..."
  if [ "$show_streams" -eq 1 ]; then
    ffprobe "$file" -v quiet -show_streams -of default=noprint_wrappers=1:nokey=1
    exit 0
  fi
  if [ "$log_comments" -eq 1 ]; then
    ffprobe "$file" -v quiet -show_entries format_tags -of default=noprint_wrappers=1:nokey=1
    exit 0
  fi
  metadata_string=""
  
  echo "$disable_default_comments"
  if [ "$disable_default_comments" -eq 0 ]; then
    base_audio_data=$(ffprobe "$file" -v quiet -show_entries stream=sample_rate,channels,bits_per_sample -of default=noprint_wrappers=1:nokey=1)
    sample_rate=$(echo "$base_audio_data" | sed -n 1p)
    channels=$(echo "$base_audio_data" | sed -n 2p)
    bit_rate=$(echo "$base_audio_data" | sed -n 3p)
    # use both time and date
    creation_date=$(stat -f "%SB" -t "%Y-%m-%d %H:%M:%S" "$file")
    # if bit_depth is N/A, use mediainfo to extract it
    if [ "$bit_rate" = "N/A" ]; then
      bit_rate=$(mediainfo --Output="Audio;%BitDepth%" "$file")
    fi
    metadata_string="source_file_name: $filename, source_sample_rate: $sample_rate, source_bit_depth: $bit_rate, source_channels: $channels, source_creation_date: $creation_date"
    # replace commas with newlines
    metadata_string=$(echo "$metadata_string" | sed 's/, /\n/g')
  fi
  
  # Append custom comments to metadata string
  for comment in "${custom_comments[@]}"; do
    metadata_string="$metadata_string/\n/comment=$comment"
  done
  
  temp_filepath="${search_path}/temp_${counter}.${file##*.}"
  echo "Adding comments to ${file}..."

  # Extract the filename before the first _
  source_file=$(echo "$filename" | cut -d'_' -f1)

  # Add metadata using ffmpeg
    ffmpeg -i "$file" -v quiet -c copy -map_metadata 0 -metadata comment="$metadata_string" "$temp_filepath"
  
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