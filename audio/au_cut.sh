#!/bin/bash

# This script takes runs aubiocut on a file with different presets
# It takes in the file name as the firts argument, the preset as the 2nd and threshold as 3d with -t or --threshold
# Example usage: aucut input_file.wav -t 0.5 -p 1

# Bash shortcut -> aucut
# You can use echo to add it to ~/.zprofile or ~/.bash_profile or ~/.bashrc, depending on your system
# echo "alias aucut=\"bash ~/path-to-script/au_cut.sh\"" >> ~/.zprofile && source ~/.zprofile


# Default threshold value and preset number
threshold=0.5
preset_number=1

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -t|--threshold)
      threshold="$2"
      shift
      shift
      ;;
    -p|--preset)
      preset_number="$2"
      shift
      shift
      ;;
    *)
      if [ -z "$input_file" ]; then
        input_file="$1"
      else
        echo "Error: Invalid argument '$1'"
        exit 1
      fi
      shift
      ;;
  esac
done

# Check if an input file is provided
if [ -z "$input_file" ]; then
  echo "Usage: $0 input_file [-t|--threshold threshold_value] [-p|--preset preset_number]"
  exit 1
fi

# Get the input file name without extension
input_filename_no_ext="${input_file%.*}"

# Set the output directory to be the same as the input file name
output_directory="$input_filename_no_ext"

# Create the output directory if it does not exist
mkdir -p "$output_directory"

# Set the aubiocut options based on the preset number
case $preset_number in
  1)
    aubiocut_options="-B 4096 -H 128 -O mkl"
    ;;
  2)
    aubiocut_options="-B 4096 -H 128 -O specdiff"
    ;;
  3)
    aubiocut_options="-B 4096 -H 1024 -O complex"
    ;;
  4)
    aubiocut_options="-O phase"
    ;;
  5)
    aubiocut_options="-B 2048 -H 128 -O specdiff"
    ;;
  6)
    aubiocut_options="-B 1024 -H 1024 -O hfc"
    ;;
  *)
    echo "Error: Invalid preset number."
    exit 2
    ;;
esac

# Cut the input audio file using aubiocut with the specified threshold and selected preset
aubiocut -c -i "$input_file" -o "$output_directory" -t "$threshold" $aubiocut_options

