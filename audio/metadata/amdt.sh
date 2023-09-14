#!/bin/bash

# This script adds metadata to all audio files in a given directory.
# Dependencies: ffmpeg, ffprobe, mediainfo (link : https://mediaarea.net/en/MediaInfo)
# Bash shortcut -> amdt
# You can use echo to add it to ~/.zprofile or ~/.bash_profile or ~/.bashrc, depending on your system
# echo "alias aumd=\"bash ~/path-to-script/audio_metadata.sh\"" >> ~/.zprofile && source ~/.zprofile

# autocomplete for input file
_amdt_complete_input_file() {
  local cur=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=( $(compgen -f -- "$cur") )
}
complete -F _amdt_complete_input_file -o filenames -o nospace amdt.sh


usage() {
  echo "Usage: amdt [-c comment] [-d] [-i input_file] [-l] [-mt metadata_template] [-s] path"
  echo
  echo "Example usage : amdt /audioFolder -c \"This is a comment\""
  echo "path: Directory path of the audio files."
  echo "-c: Optional comment to add to the metadata string. Can be used multiple times to add multiple comments."
  echo "-d: Disable default comments; source_file_name, source_sample_rate, source_bit_depth, source_channels, source_creation_date"
  echo "-i: Specify a single file to process."
  echo "-l: Log the current comments in the metadata string."
  echo "-s: Show the available streams in the file, i.e. the audio streams containing the sample rate, bit depth, etc."
  echo "-mt: Specify a metadata template file. The script will use the template to generate the metadata string."
  echo "     The template file should be a text file with one line per comment with values separated by a colon."
  echo "     For variables that you would like to extract from the audio file, use the following format: {variable_name}"
  echo "     Example:" 
  echo "     source_file_name: {source_file_name}"
  echo "     Tip: you can override the default variable names. Note that if you redefine any of the default variables, the script will assume a custom config is being used and won't add any of the default comments."
  echo "     bit-depth: {bits_per_sample}"
  echo "     To see the list of available variables, use the -s flag."
}

if [ -z "$1" ]; then
  usage
  exit 1
fi

if ! command -v ffmpeg &> /dev/null; then
  echo "Error: ffmpeg is not installed. Please install ffmpeg and try again."
  exit 4
fi

search_path=""
custom_comments=()
log_comments=0
show_streams=0
disable_default_comments=0
input_file=""
metadata_template=""


while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --comment|-c)
      custom_comments+=("$2")
      shift
      shift
      ;;
    --log|-l)
      log_comments=1
      shift
      ;;
    --show-streams|-s)
      show_streams=1
      shift
      ;;
    --input-file|-i)
      input_file="$2"
      shift
      ;;
    --disable-defaults|-dd)
      disable_default_comments=1
      shift
      ;;
    --metadata-template|-mt)
      metadata_template="$2"
      shift
      ;;
    *)
      search_path="$1"
      shift
      ;;
  esac
done

source_file_name="source_file_name"
source_sample_rate="source_sample_rate"
source_bit_depth="source_bit_depth"
source_channels="source_channels"
source_creation_date="source_creation_date"
source_duration="source_duration"
source_bit_rate="source_bit_rate"
source_codec="source_codec"
source_creation_date="source_creation_date"

# Define the file extensions to search for
file_extensions=("wav" "aif" "aiff" "flac" "mp3" "m4a" "aac")
home_dir="$(realpath ~)"
search_path="$(realpath "$search_path")"

if [ "$search_path" = "$home_dir" ]; then
  echo "Error: The script cannot be run in the home directory."
  exit 2
fi

if [ -n "$metadata_template" ] && [ ${#custom_comments[@]} -gt 0 ]; then
  echo "Error: You cannot specify both a metadata template and custom comments."
  exit 3
fi

# Find all audio files in the directory and its subdirectories
audio_files=()
for extension in "${file_extensions[@]}"; do
  # if only a single file is specified, add it to the array
  if [ -n "$input_file" ]; then
    audio_files+=("$input_file")
    search_path=$(dirname "$input_file")
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
  echo ""
  echo "Extracting details for ${file}..."
  if [ "$log_comments" -eq 1 ]; then
    ffprobe "$file" -v quiet -show_entries format_tags -of default=noprint_wrappers=1:nokey=1
    continue
  fi
  
  base_audio_data=$(ffprobe "$file" -v quiet -show_entries stream=sample_rate,channels,bits_per_sample,duration,bit_rate,codec_long_name -of default=noprint_wrappers=1:nokey=1)
  # if a bug in ffmpeg causes the first line to be the codec name, remove it
  if [[ "$base_audio_data" =~ ^[a-zA-Z0-9] ]]; then
    codec=$(echo "$base_audio_data" | sed -n 1p)
    base_audio_data=$(echo "$base_audio_data" | sed -n '2,$p')
  else
    codec=$(echo "$base_audio_data" | sed -n 1p)
    if [ -z "$codec" ]; then
      codec=$(ffprobe "$file" -v quiet -show_entries stream=codec_long_name -of default=noprint_wrappers=1:nokey=1)
    fi
  fi
  sample_rate=$(echo "$base_audio_data" | sed -n 1p)
  channels=$(echo "$base_audio_data" | sed -n 2p)
  bits_per_sample=$(echo "$base_audio_data" | sed -n 3p)
  duration=$(echo "$base_audio_data" | sed -n 4p)
  bit_rate=$(echo "$base_audio_data" | sed -n 5p)
  creation_date=$(stat -f "%SB" -t "%Y-%m-%d %H:%M:%S" "$file")
  stream_data=""
  stream_data+="source_file_name: $filename,source_sample_rate: $sample_rate,source_bit_depth: $bits_per_sample,source_channels: $channels,source_creation_date: $creation_date,source_duration: $duration,source_bit_rate: $bit_rate,source_codec: $codec"
  stream_data=$(echo "$stream_data" | sed 's/,/\n/g')

  # # if stream data is N/A or 0 or not correct, use mediainfo to extract it
  if [ "$bits_per_sample" = "N/A" ] || [ "$bits_per_sample" -eq 0 ] || [ "$((bits_per_sample & (bits_per_sample - 1)))" -ne 0 ]; then
    bits_per_sample=$(mediainfo --Output="Audio;%BitDepth%" "$file")
  fi
  if [ "$sample_rate" = "N/A" ] || [ "$sample_rate" -eq 0 ]; then
    sample_rate=$(mediainfo --Output="Audio;%SamplingRate%" "$file")
  fi
  if [ "$channels" = "N/A" ] || [ "$channels" -eq 0 ]; then
    channels=$(mediainfo --Output="Audio;%Channels%" "$file")
  fi
  
  if [ "$show_streams" -eq 1 ]; then
    echo ""
    echo "Stream data:"
    echo "$stream_data"
    continue
  fi

  # If a metadata template is specified, use it to generate the metadata string
  if [ -n "$metadata_template" ]; then
    if [ ! -f "$metadata_template" ]; then
      echo "Error: The metadata template file does not exist."
      exit 4
    fi
    while IFS= read -r line; do
      # Skip empty lines
      if [ -z "$line" ]; then
        continue
      fi
      # Skip comments
      if [[ "$line" =~ ^# ]]; then
        continue
      fi
      # Replace the variables with their names from the template and if a variable is provided
      if [[ "$line" =~ \{.*\} ]]; then
        # key in on the left of the colon and the variable name on the right
        variable_key=$(echo "$line" | sed -n 's/\([^:]*\):.*/\1/p')
        variable_name=$(echo "$line" | sed -n 's/.*{\([^}]*\)}.*/\1/p')
        variable_value=""
        if [ "$variable_name" == "$source_file_name" ]; then 
          variable_value="$filename"
          echo "$variable_value"
        elif [ "$variable_name" == "$source_sample_rate" ]; then 
          variable_value="$sample_rate"
        elif [ "$variable_name" == "$source_bit_depth" ]; then 
          variable_value="$bits_per_sample"
        elif [ "$variable_name" == "$source_channels" ]; then 
          variable_value="$channels"
        elif [ "$variable_name" == "$source_creation_date" ]; then 
          variable_value="$creation_date"
        elif [ "$variable_name" == "$source_duration" ]; then 
          variable_value="$duration"
        elif [ "$variable_name" == "$source_bit_rate" ]; then 
          variable_value="$bit_rate"
        elif [ "$variable_name" == "$source_codec" ]; then 
          variable_value="$codec"
        fi
        line=$(echo "$line" | sed "s/{${variable_name}}/${variable_value}/g")
      fi
      custom_comments+=("$line")
    done < "$metadata_template"

    # check to see if any of the default comments are in the template
    # if so assume a custom config is being used and don't add the default comments
    if [[ "${custom_comments[*]}" =~ "$filename" ]] ||
       [[ "${custom_comments[*]}" =~ "$sample_rate" ]] ||
       [[ "${custom_comments[*]}" =~ "$bits_per_sample" ]] || 
       [[ "${custom_comments[*]}" =~ "$channels" ]] ||
       [[ "${custom_comments[*]}" =~ "$creation_date" ]]; then
      disable_default_comments=1
    fi
  fi

  metadata_string=""
  echo "$disable_default_comments"
  if [ "$disable_default_comments" -eq 0 ]; then
    metadata_string="source_file_name: $filename, source_sample_rate: $sample_rate, source_bit_depth: $bits_per_sample, source_channels: $channels, source_creation_date: $creation_date"
  fi
  
  # Append custom comments to metadata string
  for comment in "${custom_comments[@]}"; do
    metadata_string+=", $comment"
  done

  # replace all the commas with newlines
  metadata_string=$(echo "$metadata_string" | sed 's/, /\n/g')
  
  temp_filepath="${search_path}/temp_${counter}.${file##*.}"
  echo "Adding comments to ${file}..."

  # Extract the filename before the first _
  source_file=$(echo "$filename" | cut -d'_' -f1)

  # Add metadata using ffmpeg
    ffmpeg -i "$file" -v error -c copy -map_metadata 0 -metadata comment="$metadata_string" "$temp_filepath"
  
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