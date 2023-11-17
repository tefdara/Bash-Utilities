#!/bin/bash

# Audio file organiser. It splits audio folders based on duration. Use -name for custom name
# Bash shortcut -> batchorder
# You can use echo to add it to ~/.zprofile or ~/.bash_profile or ~/.bashrc, depending on your system
# echo "alias batchorder=\"bash ~/path-to-script/batch_au_order.sh\"" >> ~/.zprofile && source ~/.zprofile


usage() {
  echo "Usage: ./au_order.sh directory_path [-name custom_name] ['-fl' | '-flicker' flicker_duration_ms] ['-spark' spark_duration_ms] ['-transient' transient_duration_ms] ['-sw' | '-swift' swift_duration_ms] ['-short' short_duration_ms] ['-long' long_duration_ms] ['-ct' | '-continuous' continuous_duration_ms"
  echo "Example usage: ./au_order.sh ~/Desktop/audio"
  echo ""
  echo "Default duration values:"
  echo "Flicker: 0-150ms"
  echo "Spark: 150-300ms"
  echo "Transient: 300-500ms"
  echo "Swift short: 500-1000ms"
  echo "Short: 1000-2000ms"
  echo "Average: 2000-5000ms"
  echo "Long: 5000-10000ms"
  echo "Continuous: 10000ms+"
}

if [ -z "$1" ]; then
  usage
  exit 1
fi

search_path="$1"
shift

custom_name=""
flicker_duration_ms=150
spark_duration_ms=300
transient_duration_ms=500
swift_duration_ms=1000
short_duration_ms=2000
long_duration_ms=5000
continuous_duration_ms=10000

while [ "$#" -gt 0 ]; do
  case "$1" in
      -name)
        custom_name="$2"
        shift 2
        ;;
      -fl | -flicker)
        flicker_duration_ms="$2"
        shift 2
        ;;
      -spark)
        spark_duration_ms="$2"
        shift 2
        ;;
      -transient)
        transient_duration_ms="$2"
        shift 2
        ;;
      -sw | -swift)
        swift_duration_ms="$2"
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
      -ct | -continuous)
        continuous_duration_ms="$2"
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
average_counter=1
long_counter=1

# if there is an analysis folder in the directory, also look inside that and copy the corresponding analysis file for each audio file
if [ -d "${search_path}/analysis" ]; then
  analysis_files=("${search_path}/analysis"/*.txt)
  for file in "${audio_files[@]}"; do
    filename=$(basename "$file")
    analysis_file="${search_path}/analysis/${filename}.txt"
    if [ -f "$analysis_file" ]; then
      audio_files+=("$analysis_file")
    fi
  done
fi

for file in "${audio_files[@]}"; do
  file_duration_ms=$(mediainfo --Output="Audio;%Duration%" "$file")

  if [ "$file_duration_ms" -le "$flicker_duration_ms" ]; then
    category="flicker"
    counter=$flicker_counter
    flicker_counter=$((flicker_counter + 1))
  elif [ "$file_duration_ms" -le "$spark_duration_ms" ]; then
    category="spark"
    counter=$spark_counter
    spark_counter=$((spark_counter + 1))
  elif [ "$file_duration_ms" -le "$transient_duration_ms" ]; then
    category="transient"
    counter=$transient_counter
    transient_counter=$((transient_counter + 1))
  elif [ "$file_duration_ms" -le "$swift_duration_ms" ]; then
    category="swift"
    counter=$swift_counter
    swift_counter=$((swift_counter + 1))
  elif [ "$file_duration_ms" -le "$short_duration_ms" ]; then
    category="short"
    counter=$short_counter
    short_counter=$((short_counter + 1))
  elif [ "$file_duration_ms" -le "$long_duration_ms" ]; then
    category="average"
    counter=$average_counter
    average_counter=$((average_counter + 1))
  elif [ "$file_duration_ms" -le "$continuous_duration_ms" ]; then
    category="long"
    counter=$long_counter
    long_counter=$((long_counter + 1))
  else
    category="continuous"
    counter=$continuous_counter
    continuous_counter=$((continuous_counter + 1))
  fi

  filename=$(basename "$file")
  filename="${filename%.*}"
  analysis_file="${search_path}/analysis/${filename}_analysis.json"
  if [ -f "$analysis_file" ]; then
    echo "Found analysis file for $filename"
    echo "Copying analysis file to ${search_path}/${category}/${filename}_analysis.json"
    mkdir -p "${search_path}/${category}/analysis"
    anal_copy="${search_path}/${category}/analysis/${filename}_analysis.json"
    cp "$analysis_file" "$anal_copy"
  fi

  mkdir -p "${search_path}/${category}"

  if [ -n "$custom_name" ]; then
    new_filename="${custom_name}_${category}_${counter}.wav"
  else
    new_filename=$(basename "$file")
  fi

  new_filepath="${search_path}/${category}/${new_filename}"
  echo "$analysis_file"
  echo "Copying $file to $new_filepath"
  cp "$file" "$new_filepath"
done

echo ""
echo "Done!"
echo ""
echo "Summary:"
echo "Flicker: $flicker_counter"
echo "Spark: $spark_counter"
echo "Transient: $transient_counter"
echo "Swift short: $swift_counter"
echo "Short: $short_counter"
echo "Average: $average_counter"
echo "Long: $long_counter"
echo "Continuous: $continuous_counter"
# sum all the counters to make sure we have all the files
# its ok if this number is higher than the number of files, because some files might be in multiple categories
echo "Total: $((flicker_counter + spark_counter + transient_counter + swift_counter + short_counter + average_counter + long_counter + continuous_counter))"
