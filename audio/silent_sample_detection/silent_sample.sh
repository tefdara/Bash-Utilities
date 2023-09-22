#!/bin/bash

# This script uses ffmpeg to find sounds with mean volume below a certain threshold
# Usage: silentsample path [-t threshold]

# Bash shortcut -> silentsamp
# You can use echo to add it to ~/.zprofile or ~/.bash_profile or ~/.bashrc, depending on your system
# echo "alias silentsamp=\"bash ~/path-to-script/silent_sample.sh\"" >> ~/.zprofile && source ~/.zprofile


# Define the file extensions to search for
file_extensions=("wav" "aif" "aiff" "flac" "mp3")

# Check if the user provided a directory to search
if [ $# -lt 1 ]; then
  echo "Please provide a directory to search for audio files."
  exit 1
fi

# Safety check: prevent the script from running in the home directory
home_dir="$(realpath ~)"
search_path="$(realpath "$1")"
if [ "$search_path" = "$home_dir" ]; then
  echo "Error: The script cannot be run in the home directory."
  exit 2
fi

# Set the silent threshold
if [ $# -eq 2 ]; then
  silent_threshold="$2"
else
  silent_threshold="-40"
fi

# Find all audio files in the directory and its subdirectories
audio_files=()
for extension in "${file_extensions[@]}"; do
  while IFS=  read -r -d $'\0'; do
      audio_files+=("$REPLY")
  done < <(find "$search_path" -type f -name "*.$extension" -print0)
done

# Check if any audio files were found
if [[ ${#audio_files[@]} -eq 0 ]]; then
    echo "No audio files found in $search_path"
    exit 3
fi

silent_files=()
echo analyzing "${#audio_files[@]}" files
# Loop through each audio file and check if it's silent
for file in "${audio_files[@]}"; do
  # Use ffmpeg to get the volume of the audio file
  volume=$(ffmpeg -i "$file" -af "volumedetect" -f null /dev/null 2>&1 | grep "mean_volume:" | awk '{print $5}')
#   echo "Volume for $file is $volume"

echo "analyising file $counter of ${#audio_files[@]} "
  # Check if the volume is zero
  if (( $(echo "$volume < $silent_threshold" | bc -l) )); then
    silent_files+=("$file")
  fi
  counter=$((counter+1))
done

# Check if there are any silent audio files
if [[ ${#silent_files[@]} -gt 0 ]]; then  
    echo "The following silent audio files were found:"
    for silent_file in "${silent_files[@]}"; do  
        echo "$silent_file"  # Print the name of the silent audio file
    done
    # Ask the user if they want to move the silent audio files
    read -p "Do you want to move these files to the Silent_Audio directory? [y/N] " response  
    case "$response" in
    [yY][eE][sS]|[yY])  
        # Set the directory to move the silent audio files to
        silent_dir=~/Silent_Audio  
        if [[ ! -d $silent_dir ]]; then  # If the directory doesn't exist, create it
            mkdir -p "$silent_dir"
        fi

        # Move the silent audio file to the silent audio directory
        for silent_file in "${silent_files[@]}"; do  
            mv "$silent_file" "$silent_dir/"  
            echo "Moved $silent_file to $silent_dir" 
        done
        ;;
    *) 
        exit 0
        ;;
    esac
else
    echo "No silent audio files found." 
    exit 0 
fi

# Set the directory to move the silent audio files to
silent_dir=~/Silent_Audio  
if [[ ! -d $silent_dir ]]; then  # If the directory doesn't exist, create it
    mkdir -p "$silent_dir"
fi

# Move the silent audio file to the silent audio directory
for silent_file in "${silent_files[@]}"; do  
    mv "$silent_file" "$silent_dir/"  
    echo "Moved $silent_file to $silent_dir" 
done

