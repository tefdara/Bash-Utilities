#!/bin/bash

# Generic file renamer. It cuts from _ and enumarates. Use -name for custom name

# Bash shortcut -> batchrename
# You can use echo to add it to ~/.zprofile or ~/.bash_profile or ~/.bashrc, depending on your system
# echo "alias batchname=\"bash ~/path-to-script/batch_name.sh\"" >> ~/.zprofile && source ~/.zprofile


usage() {
  echo
  echo -e "\033[33mUsage: batchname directory_path [-ext file_extension] [-name custom_name] [-append append_text]\033[0m"
  echo
  echo -e "\033[36mExample: batchname ~/Music/MyAlbum -ext wav -name NewAlbum -> NewAlbum_1.wav, NewAlbum_2.wav, ...\033[0m"
  echo
  echo -e "\033[36mExample: batchname ~/Music/MyAlbum -name NewAlbum -> NewAlbum_1.wav, NewAlbum_2.wav, ...\033[0m"
  echo -e "Or"
  echo -e "\033[36mExample: batchname ~/Music/MyAlbum -> MyAlbum_1.wav, MyAlbum_2.wav, ... \033[0m"
  echo
  echo -e "You can also use % in the custom name to enumerate the files."
  echo -e "\033[36mExample: batchname ~/Music/MyAlbum -name MyAlbum_%_Take -> MyAlbum_1_Take_1.wav, MyAlbum_2_Take_2.wav, ...\033[0m"
  echo
  echo -e "You can use -append to append text to the original name."
  echo -e "\033[36mExample: batchname ~/Music/MyAlbum -append _remastered -> Track_1_remastered.wav, Track_2_remastered.wav, ...\033[0m"
  echo
  echo -e "You can also use % in the append text to enumerate the files."
  echo -e "\033[36mExample: batchname ~/Music/MyAlbum -append _remastered_% -> Track_1_remastered_1.wav, Track_2_remastered_2.wav, ...\033[0m"
  echo 
  echo -e "You can rename all file extensions by using -all"
  echo -e "\033[36mExample: batchname ~/Music/MyAlbum -all -name NewAlbum -> NewAlbum_1.wav, NewAlbum_2.mp3, ...\033[0m"
}

if [ -z "$1" ]; then
  usage
  exit 1
fi

search_path="$1"
shift

custom_name=""
append_text=""
extension="wav"
all_extensions=false

while [ "$#" -gt 0 ]; do
  case "$1" in
    -name)
      custom_name="$2"
      shift 2
      ;;
    -append)
      append_text="$2"
      shift 2
      ;;
    -ext)
      extension="$2"
      shift 2
      ;;
    -all)
      all_extensions=true
      shift 1
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

if [ ! -d "$search_path" ]; then
  echo "Error: The directory does not exist."
  exit 2
fi

if [ "$search_path" = "." ]; then
  search_path="$(realpath .)"
fi
if ["$custom_name" eq ""]; then
  custom_name=$(basename "$search_path")
  echo "Using $custom_name as custom name"
fi


files=()
if [ "$all_extensions" = true ]; then
  shopt -s nullglob
  files=("$search_path"/*)
else
  shopt -s nullglob
  files=("$search_path"/*."$extension")
fi


if [[ ${#files[@]} -eq 0 ]]; then
    echo "No files found! Make sure you pass the right directory";
    exit 1
fi

temp_files=()
counter=1
for file in "${files[@]}"; do
  # Use custom name or remove everything after the underscore
  if [ -n "$custom_name" ]; then
    # Check if custom_name has % and replace it with counter
    if [[ "$custom_name" == *%* ]]; then
        base_name="${custom_name/\%/$counter}"
        filename_without_ext="${base_name}_${counter}"
    else
        filename_without_ext="${custom_name}_${counter}"
    fi
  else
    filename=$(basename "$file")
    filename_without_ext="${filename%%_*}_${counter}"
  fi

# Append text to the filename
if [ -n "$append_text" ]; then
  filename_without_ext="${filename%%.*}"
  if [[ "$append_text" == *%* ]]; then
    filename_without_ext="${filename_without_ext}_${append_text/\%/$counter}"
  else
    filename_without_ext="${filename_without_ext}_$append_text"
  fi
fi

  # Get the file extension
  file_ext="${file##*.}"

  # Rename the file
  new_filepath="${search_path}/${filename_without_ext}.${file_ext}"
  if [ "$file" != "$new_filepath" ]; then
    # create a temp file to avoid overwriting other files with the same name
    temp_filepath="${search_path}/temp_${filename_without_ext}.${file_ext}"
    echo "Creating $temp_filepath"
    mv "$file" "$temp_filepath"
    temp_files+=("$temp_filepath")
  fi

  counter=$((counter + 1))
done

# Rename the temp files
for temp_file in "${temp_files[@]}"; do
  filename=$(basename "$temp_file")
  filename_without_ext="${filename%%.*}"
  filename_without_ext="${filename_without_ext#temp_}"
  file_ext="${temp_file##*.}"
  new_filepath="${search_path}/${filename_without_ext}.${file_ext}"
  echo "Renaming $temp_file to $new_filepath"
  mv "$temp_file" "$new_filepath"
done