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
prepend_text=""
extension="wav"
split_char=""
all_extensions=false
rename_dirs=false
enum=false
recursive=false


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
    -prepend)
      prepend_text="$2"
      shift 2
      ;;
    -s | -split)
      split_char="$2"
      shift 2
      ;;
    -ext)
      extension="$2"
      shift 2
      ;;
    -a | -all)
      all_extensions=true
      shift 1
      ;;
    -d | -dir)
      rename_dirs=true
      shift 1
      ;;
    -en | -enum)
      enum=true
      shift 1
      ;;
    -r | -rec)
      recursive=true
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

# Safety check: prevent the script from running in the root directory
if [ "$search_path" = "/" ]; then
  echo "Error: The script cannot be run in the root directory."
  exit 2
fi

if [ ! -d "$search_path" ]; then
  echo "Error: The directory does not exist."
  exit 2
fi

if [ "$search_path" = "." ]; then
  search_path="$(realpath .)"
fi

files=()


shopt -s nullglob
if [ "$all_extensions" = true ] && [ "$rename_dirs" = false ]; then
  if [ "$recursive" = true ]; then
    files=("$search_path"/**/*)
  else
    files=("$search_path"/*)
  fi

elif [ "$all_extensions" = false ] && [ "$rename_dirs" = false ]; then
  if [ "$recursive" = true ]; then
    files=("$search_path"/**/*."$extension")
  else
    files=("$search_path"/*."$extension")
  fi

elif [ "$all_extensions" = true ] && [ "$rename_dirs" = true ]; then
  echo "Error: You cannot use -all and -dir at the same time"
  exit 1

elif [ "$rename_dirs" = true ]; then
  files=()
  if [ "$recursive" = true ]; then
    for dir in "$search_path"/**/*; do
      if [ -d "$dir" ]; then
        files+=("$dir")
      fi
    done
  else
    for dir in "$search_path"/*; do
      if [ -d "$dir" ]; then
        files+=("$dir")
      fi
    done
  fi
fi

echo "Found ${#files[@]} files"
if [[ ${#files[@]} -eq 0 ]]; then
    echo "No files found! Make sure you pass the right directory";
    exit 1
fi

counter_string=""
if [ "$enum" = true ]; then
  counter=1
  counter_string="_$counter"
else
  counter=""
fi

temp_files=()

rename() {

  temp_counter=1
  for file in "${files[@]}"; do
    if [ "$custom_name" = "" ]; then
      if [ -d "$file" ]; then
        custom_name=$(basename "$file")
      else
        custom_name=$(dirname "$file")
        custom_name="${custom_name##*/}"
      fi
      echo "Using $custom_name as custom name"
    fi
    # Use custom name or remove everything after the underscore
    if [ -n "$custom_name" ]; then
      # Check if custom_name has % and replace it with counter
      if [[ "$custom_name" == *%* ]]; then
          base_name="${custom_name/\%/$counter}"
          filename_without_ext="${base_name}${counter_string}"
      else
          filename_without_ext="${custom_name}${counter_string}"
      fi
    else
      filename=$(basename "$file")
      filename_without_ext="${filename%%_*}${counter_string}"
    fi

    # Prepend 
    if [ -n "$prepend_text" ]; then
      filename_without_ext="${prepend_text}_${filename_without_ext}"
    fi 

    # Append 
    if [ -n "$append_text" ]; then
      filename_without_ext="${filename%%.*}"
      if [[ "$append_text" == *%* ]]; then
        filename_without_ext="${filename_without_ext}_${append_text/\%/$counter_string}"
      else
        filename_without_ext="${filename_without_ext}_$append_text"
      fi
    fi

    # Split
    if [ -n "$split_char" ]; then
      filename_without_ext="${filename_without_ext%%$split_char*}"
    fi
    
    if [ -d "$file" ]; then
      file_ext=""
    else
      file_ext=".${file##*.}"
    fi

    file_path=$(dirname "$file")
    new_filepath="${file_path}/${filename_without_ext}${file_ext}"
    
    if [ "$file" != "$new_filepath" ]; then
      temp_filepath="${file_path}/temp_${filename_without_ext}_${temp_counter}${file_ext}"
      echo "Creating $temp_filepath"
      if [ -e "$temp_filepath" ]; then
        echo "Error: $temp_filepath already exists"
      else
        # echo "Moving $file to $temp_filepath"
        mv "$file" "$temp_filepath"
        temp_files+=("$temp_filepath")
      fi
    else
      echo "Error: $file is already named correctly"
    fi


    if [ "$enum" = true ] || [[ "$custom_name" == *%* ]]; then
      counter=$((counter + 1))
      counter_string="_$counter"
    fi
    
    if [ "$recursive" = true ]; then
      custom_name=""
    fi
    temp_counter=$((temp_counter + 1))
  done
}

rename 

if [ ${#temp_files[@]} -eq 0 ]; then
  echo "No files to rename"
  exit 1
fi

for temp_file in "${temp_files[@]}"; do
  echo "Renaming $temp_file"
  filename=$(basename "$temp_file")
  filename_without_ext="${filename%%.*}"
  filename_without_ext="${filename_without_ext#temp_}"
  filename_without_ext="${filename_without_ext%_*}"
  
  if [ -d "$temp_file" ]; then
    file_ext=""
  else
    file_ext=".${temp_file##*.}"
  fi
  
  file_path=$(dirname "$temp_file")

  new_filepath="${file_path}/${filename_without_ext}${file_ext}"
  
  if [ -e "$new_filepath" ]; then
    counter=1
    while [ -e "${file_path}/${filename_without_ext}_${counter}${file_ext}" ]; do
      counter=$((counter + 1))
    done
    new_filepath="${file_path}/${filename_without_ext}_${counter}${file_ext}"
  fi
  
  if [ -n "$new_filepath" ]; then
    mv "$temp_file" "$new_filepath"
  fi
done
