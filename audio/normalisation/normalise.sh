#!/bin/bash

# Normalize audio files in a directory and its subdirectories
# It takes in the directory path as the first argument and the gain as the second with -g or --gain
# Example usage: normaudio /audioFolder -g -2

# Bash shortcut -> normaudio
# You can use echo to add it to ~/.zprofile or ~/.bash_profile or ~/.bashrc, depending on your system
# echo "alias normaudio=\"bash ~/path-to-script/normaudio.sh\"" >> ~/.zprofile && source ~/.zprofile

#!/bin/bash

usage() {
  echo "Usage: normaudio path [-g gain]"
  echo
  echo "Example usage : normaudio /audioFolder -g -2"
  echo "path: Directory path of the audio files."
  echo "-g: Define the gain for normalization. If not provided, the default is -3 dB."
}

if [ -z "$1" ]; then
  usage
  exit 1
fi

if [ "$1" == "--help" ]; then
  usage
  exit 0
fi

search_path="$1"
shift

gain=-3

while [ "$#" -gt 0 ]; do
  case "$1" in
    -g)
      gain="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

file_extensions=("wav" "aif" "aiff" "flac" "mp3" "m4a" "aac")
home_dir="$(realpath ~)"
search_path="$(realpath "$search_path")"

if [ "$search_path" = "$home_dir" ]; then
  echo "Error: The script cannot be run in the home directory."
  exit 2
fi

audio_files=()
for extension in "${file_extensions[@]}"; do
  while IFS=  read -r -d $'\0'; do
      audio_files+=("$REPLY")
  done < <(find "$search_path" -type f -name "*.$extension" -print0)
done

if [[ ${#audio_files[@]} -eq 0 ]]; then
    echo "No audio files found! Make sure you pass the right directory";
    exit 1
fi

counter=1
for file in "${audio_files[@]}"; do

  base_filename=$(basename "$file")
  extension="${base_filename##*.}"
  temp_filepath="${search_path}/temp_${counter}.${extension}"
  sox_command="gain -n ${gain}"

  # Get the sample rate and bit depth of the audio file
  sample_rate=$(soxi -r "$file")
  bit_depth=$(soxi -b "$file")

  # Add the sample rate and bit depth to the sox command
  sox_command+=" rate $sample_rate"
  echo ""
  sox "$file" "-b $bit_depth" "$temp_filepath" $sox_command
  echo "Processing ${file}"
  if [ $? -ne 0 ]; then
    echo "Error processing file: ${file}"
    rm -f "$temp_filepath"
    continue
  fi
  echo "gain: ${gain}dB sample_rate: ${sample_rate}khz bit_depth: ${bit_depth}"
  # Remove the original file and rename the processed file
  if [ -f "$temp_filepath" ]; then
    if [ -f "$file" ]; then
      rm "$file"
    else
      echo "Error: Source File not found: ${file}"
      rm -f "$temp_filepath"
      continue
    fi
    mv "$temp_filepath" "$file"
  else
    echo "Error: Temp File not found: ${temp_filepath}"
    continue
  fi
done
