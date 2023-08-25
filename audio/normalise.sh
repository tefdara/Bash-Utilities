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

# Safety check: prevent the script from running in the home directory
home_dir="$(realpath ~)"
search_path="$(realpath "$search_path")"
if [ "$search_path" = "$home_dir" ]; then
  echo "Error: The script cannot be run in the home directory."
  exit 2
fi

while IFS=  read -r -d $'\0'; do
    audio_files+=("$REPLY")
done < <(find "$search_path" -type f -name '*.wav' -print0)

if [[ ${#audio_files[@]} -eq 0 ]]; then
    echo "No audio files found! Make sure you pass the right directory";
    exit 1
fi

for file in "${audio_files[@]}"; do
  temp_filepath="${file%.*}_temp.wav"
  sox_command="gain -n ${gain}"

  sox "$file" "$temp_filepath" $sox_command
  echo "Processing ${file}"
  if [ $? -ne 0 ]; then
    echo "Error processing file: ${file}"
    rm -f "$temp_filepath"
    continue
  fi

  # Remove the original file and rename the processed file
  rm "$file"
  mv "$temp_filepath" "$file"
done
