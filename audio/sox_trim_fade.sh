#!/bin/bash

# Runs SOX to trim silence add fades, normalise and rename files
# Requires sox to be installed
# pip install sox

# Bash shortcut -> trimfade
# You can use echo to add it to ~/.zprofile or ~/.bash_profile or ~/.bashrc, depending on your system
# echo "alias trimfade=\"bash ~/path-to-script/sox_trim_fade.sh\"" >> ~/.zprofile && source ~/.zprofile

usage() {
  echo "Usage: trimfade path [-t audio_format] [--name new_file_name] [--rev] [-l preset] [-hpf highpass_filter_frequency]"
  echo
  echo "Example usage : trimfade /audioFolder -t mp3 --name bass_transient -l short -hpf 60"
  echo "path: Directory path of the audio files."
  echo "-t: Audio file type to process. Default is 'wav'."
  echo "--name: Provide a custom name for processed files. Default is the original name."
  echo "--rev: Add this flag to reverse the audio."
  echo "-l: Choose a length preset for triming. Options are 'long', 'short', and 'stich'. 
        Long applies a 100ms fade in and out, short applies a 20ms fade in and out, and stich applies a 100ms fade in and out with no silence trimming. Default is 'long'."
  echo "--hpf: Define the highpass filter frequency. If not provided, the default is 40 Hz."
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

audio_format="wav"
while [ "$#" -gt 0 ]; do
  case "$1" in
    -t)
      audio_format="$2"
      shift 2
      ;;
    --name)
      custom_name="$2"
      shift 2
      ;;
    --rev)
      reverse_option="--rev"
      shift
      ;;
    -l)
      preset="$2"
      shift 2
      ;;
    --hpf)
      highpass_filter_frequency="$2"
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

audio_files=($(find "$search_path" -type f -name "*.$audio_format"))

if [[ ${#audio_files[@]} -eq 0 ]]; then
    echo "No audio files found! Make sure you pass the right directory and format";
    exit 1
fi

counter=1
while IFS= read -r -d $'\0' file; do
  # Trim silence and add 20ms fade
  temp_filepath="${search_path}/temp_${counter}.$audio_format"
  sox_command="gain -n -3 -b 24 highpass ${highpass_filter_frequency} "

  case "$preset" in
    long)
      sox_command+="silence 1 0.1 0.1% reverse silence 1 0.1 0.1% reverse"
      ;;
    short)
      sox_command+="silence 1 0.02 1% reverse silence 1 0.02 1% reverse"
      ;;
    stich)
      sox_command+="silence 1 0.1 1% -1 0.1 1%"
      ;;
    *)
      echo "Error: Unknown preset. Please use 'long' or 'short' or 'stich'."
      exit 1
      ;;
  esac

  sox_command+=" fade t 0:0:0.01t reverse fade t 0:0:0.01t reverse"

  if [ "$reverse_option" == "--rev" ]; then
    sox_command+=" reverse"
  fi

  sox "$file" "$temp_filepath" $sox_command

  if [ $? -ne 0 ]; then
    echo "Error processing file: ${file}"
    rm -f "$temp_filepath"
    continue
  fi

  # Remove the original file
  rm "$file"

  # Use custom name or remove everything after the underscore
  if [ -n "$custom_name" ]; then
    new_filename="${custom_name}_${counter}.$audio_format"
  else
    filename=$(basename "$file")
    new_filename="${filename%%_*}_${counter}.$audio_format"
  fi

  # Rename the file
  new_filepath="${search_path}/${new_filename}"
  if [ "$temp_filepath" != "$new_filepath" ]; then
    echo "Processing and renaming ${file} to ${new_filepath}"
    mv "$temp_filepath" "$new_filepath"
  fi

  # Increment the counter
  counter=$((counter + 1))
done < <(find "$search_path" -type f -name "*.$audio_format" -print0)