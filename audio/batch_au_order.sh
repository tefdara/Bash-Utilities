#!/bin/bash

# Audio file organiser. It splits audio folders based on duration. Use -name for custom name
# Bash shortcut -> batchorder
# You can use echo to add it to ~/.zprofile or ~/.bash_profile or ~/.bashrc, depending on your system
# echo "alias batchorder=\"bash ~/path-to-script/batch_au_order.sh\"" >> ~/.zprofile && source ~/.zprofile


usage() {
  echo "Usage: organize_audio directory_path [-name custom_name] [-trans transient_duration_ms] [-short short_duration_ms] [-long long_duration_ms]"
}

if [ -z "$1" ]; then
  usage
  exit 1
fi

search_path="$1"
shift

custom_name=""
transient_duration_ms=500
short_duration_ms=1000
long_duration_ms=5000

while [ "$#" -gt 0 ]; do
  case "$1" in
    -name)
      custom_name="$2"
      shift 2
      ;;
    -trans)
      transient_duration_ms="$2"
      shift 2
      ;;
    -short)
      short_duration_ms="$2"
      shift 2
      ;;
    -long)
      long_duration_ms="$2"
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
if [ "$search_path" = "$home_dir" ]; then
  echo "Error: The script cannot be run in the home directory."
  exit 2
fi

shopt -s nullglob
audio_files=("$search_path"/*.wav)

if [[ ${#audio_files[@]} -eq 0 ]]; then
    echo "No audio files found! Make sure you pass the right directory";
    exit 1
fi

transient_counter=1
short_counter=1
medium_counter=1
long_counter=1

for file in "${audio_files[@]}"; do
  file_duration_ms=$(mediainfo --Output="Audio;%Duration%" "$file")

  if [ "$file_duration_ms" -le "$transient_duration_ms" ]; then
    category="transient"
    counter=$transient_counter
    transient_counter=$((transient_counter + 1))
  elif [ "$file_duration_ms" -le "$short_duration_ms" ]; then
    category="short"
    counter=$short_counter
    short_counter=$((short_counter + 1))
  elif [ "$file_duration_ms" -le "$long_duration_ms" ]; then
    category="medium"
    counter=$medium_counter
    medium_counter=$((medium_counter + 1))
  else
    category="long"
    counter=$long_counter
    long_counter=$((long_counter + 1))
  fi

  mkdir -p "${search_path}/${category}"

  if [ -n "$custom_name" ]; then
    new_filename="${custom_name}_${category}_${counter}.wav"
  else
    filename=$(basename "$file")
    new_filename="${filename%%_*}_${category}_${counter}.wav"
  fi

  new_filepath="${search_path}/${category}/${new_filename}"
  mv "$file" "$new_filepath"
done
