#!/bin/bash

# This script will group files with the same name but different extensions in a new directory
# It takes in the source directory as the first argument
# The source extension is optional and if not provided, the script will use wav as the default
# The target directory is optional and if not provided, the script will use the source directory
# The new directory is optional and if not provided, the script will create a new directory with the source file name one level up from the source directory

# Bash shortcut -> groupfiles

usage() {
    echo "Usage: group_files source_directory [-ex source_extension] [-t target_directory] [-nd new_directory]"
}

if [ -z "$1" ]; then
    usage
    exit 1
fi

source_directory="$1"
shift

target_directory="$source_directory"
new_directory="grouped_files"
source_extension="wav"

while [ "$#" -gt 0 ]; do
  case "$1" in
    -ex)
      source_extension="$2"
      shift 2
      ;;
    -t)
      target_directory="$2"
      shift 2
      ;;
    -nd)
      new_directory="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

home_dir="$(realpath ~)"
if [ "$search_path" = "$home_dir" ] || [ "$target_directory" = "$home_dir" ]; then
  echo "Are you sure you want to run the script in the home directory? (y/n)"
    read -r answer
    if [ "$answer" != "${answer#[Yy]}" ]; then
        echo "Exiting..."
        exit 2
    fi
fi

shopt -s nullglob
source_files="$(find "$source_directory" -type f -name "*.$source_extension")"

if [[ ${#source_files[@]} -eq 0 ]]; then
        echo "No files found in source directory! Make sure you pass the right directory";
        exit 1
fi

for file in "${source_files[@]}"; do
    filename=$(basename "$file")
    extension="${filename##*.}"
    filename="${filename%.*}"

    echo "Processing $filename"

    target_files=()
    while IFS= read -r -d $'\0'; do
        target_files+=("$REPLY")
    done < <(find "$target_directory" -type f -name "$filename.*" -not -name "$filename.$extension" -print0)
    
    if [[ ${#target_files[@]} -eq 0 ]]; then
        echo "No files found with same name in target directory"
        continue
    fi
    new_directory=$(basename "$file")
    new_directory="${new_directory%.*}"
    new_directory="../${new_directory}"
    mkdir -p "$new_directory"
    mv "$file" "${new_directory}/${filename}.${extension}"
    for target_file in "${target_files[@]}"; do
        if [ -f "$target_file" ]; then
            echo "Found a match in target directory: $target_file"
            base_target_file=$(basename "$target_file")
            echo "Moving $target_file to $new_directory"
            mv "$target_file" "${new_directory}/${base_target_file}"
        fi
    done
done
