#!/bin/bash

# Audio file organiser. It splits audio folders based on duration. Use -name for custom name
# Bash shortcut -> batchorder
# You can use echo to add it to ~/.zprofile or ~/.bash_profile or ~/.bashrc, depending on your system
# echo "alias batchorder=\"bash ~/path-to-script/batch_au_order.sh\"" >> ~/.zprofile && source ~/.zprofile


usage() {
  echo "Usage: ./au_order.sh directory_path [-name custom_name] [-transient transient_duration_ms] [-short short_duration_ms] [-medium medium_duration_ms] [-long long_duration_ms] [-ppp ppp_threshold] [-pp pp_threshold] [-p p_threshold] [-mp mp_threshold] [-mf mf_threshold] [-f f_threshold] [-ff ff_threshold]"
  echo ""
  echo "Default duration values:"
  echo "Transient: 0-300ms"
  echo "Short: 300-1000ms"
  echo "Med: 1000-3000ms"
  echo "Long: 3000-10000ms"

  echo ""
  echo "Default dynamic values:"
  echo "ppp: -30 to -25"
  echo "pp: -25 to -20"
  echo "p: -20 to -15"
  echo "mp: -15 to -10"
  echo "mf: -10 to -5"
  echo "f: -5 to 0"
  echo "ff: 0 to 5"
}

if [ -z "$1" ]; then
  usage
  exit 1
fi

search_path="$1"
shift

custom_name=""
categorise_durations=true
transient_duration_ms=300
short_duration_ms=1000
medium_duration_ms=3000
long_duration_ms=10000

ppp_threshold=-30
pp_threshold=-25
p_threshold=-20
mp_threshold=-15
mf_threshold=-10
f_threshold=-5
ff_threshold=0



while [ "$#" -gt 0 ]; do
  case "$1" in
      -name)
        custom_name="$2"
        shift 2
        ;;
      -no-durations | -nd)
        categorise_durations=false
        shift 1
        ;;
      -transient | -t)
        transient_duration_ms="$2"
        shift 2
        ;;
      -short | -s)
        short_duration_ms="$2"
        shift 2
        ;;
      -medium | -m)
        medium_duration_ms="$2"
        shift 2
        ;;
      -long | -l)
        long_duration_ms="$2"
        shift 2
        ;;
      -extended | -e)
        extended_duration_ms="$2"
        shift 2
      ;;
      -ppp)
      ppp_threshold="$2"
        shift 2
      ;;
      -pp)
      pp_threshold="$2"
        shift 2
      ;;
      -p)
      p_threshold="$2"
        shift 2
      ;;
      -mp)
      mp_threshold="$2"
        shift 2
      ;;
      -mf)
      mf_threshold="$2"
        shift 2
      ;;
      -f)
      f_threshold="$2"
        shift 2
      ;;
      -ff)
      ff_threshold="$2"
        shift 2
      ;;
    -h | --help)
      usage
      exit 0
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

categorize_intensity() {
    local file=$1
    local rms_db=$(sox "$file" -n stats 2>&1 | awk '/RMS lev dB/ {print $4}')
    local intensity=""

    if (( $(echo "$rms_db < -35" | bc -l) )); then
        intensity="fff"  # pianississimo
    elif (( $(echo "$rms_db < -25" | bc -l) )); then
        intensity="ff"   # pianissimo
    elif (( $(echo "$rms_db < -20" | bc -l) )); then
        intensity="f"    # piano
    elif (( $(echo "$rms_db < -15" | bc -l) )); then
        intensity="mf"   # mezzo-piano
    elif (( $(echo "$rms_db < -10" | bc -l) )); then
        intensity="mp"   # mezzo-forte
    elif (( $(echo "$rms_db < -5" | bc -l) )); then
        intensity="p"    # forte
    elif (( $(echo "$rms_db < 0" | bc -l) )); then
        intensity="pp"   # fortissimo
    else
        intensity="ppp"  # fortississimo
    fi

    echo $intensity
}

transient_counter=1
short_counter=1
medium_counter=1
long_counter=1
extended_counter=1
name_counter=1

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

categorized_files=()

for file in "${audio_files[@]}"; do
  file_duration_ms=$(mediainfo --Output="Audio;%Duration%" "$file")
  dynamic_category=$(categorize_intensity "$file")

  if [[ " ${categorized_files[@]} " =~ " ${file} " ]]; then
    echo "$file has already been categorized"
    continue
  fi

  if [ "$categorise_durations" = false ]; then
    category="Uncategorised"
    dur_code_name=""
    counter=0
    categorized_files+=("$file")

  elif [ "$file_duration_ms" -le "$transient_duration_ms" ]; then
    category="Transient"
    dur_code_name="T"
    counter=$transient_counter
    transient_counter=$((transient_counter + 1))
    categorized_files+=("$file")

  elif [ "$file_duration_ms" -le "$short_duration_ms" ]; then
    category="Short"
    dur_code_name="S"
    counter=$short_counter
    short_counter=$((short_counter + 1))
    categorized_files+=("$file")

  elif [ "$file_duration_ms" -le "$medium_duration_ms" ]; then
    category="Medium"
    dur_code_name="M"
    counter=$medium_counter
    medium_counter=$((medium_counter + 1))
    categorized_files+=("$file")

  elif [ "$file_duration_ms" -le "$long_duration_ms" ]; then
    category="Long"
    dur_code_name="L"
    counter=$long_counter
    long_counter=$((long_counter + 1))
    categorized_files+=("$file")

  else
    category="Extended"
    dur_code_name="E"
    counter=$extended_counter
    extended_counter=$((extended_counter + 1))
    categorized_files+=("$file")
  fi

  counter=$(printf "%03d" "$counter")

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
    new_filename="${custom_name}_${dur_code_name}_${dynamic_category}_${counter}.wav"
  else
    # filename="${filename%%[0-9_]*}"
    # filename without extension
    if [[ categorise_durations = true ]]; then
      dur_code_name="_${dur_code_name}"
    fi

    dynamic_category="_${dynamic_category}"

    filename="${filename%.*}"
    if [[ $filename == *-[0-9]* ]]; then
      filename="${filename%-*}"
    elif [[ $filename == *_[0-9]* ]]; then
      filename="${filename%_*}"
    fi

    new_filename="${filename}${dur_code_name}${dynamic_category}.wav"
    
    if [ -e "${search_path}/${category}/${new_filename}" ]; then
      # get the last number in the filename after the last underscore or hyphen
      name_counter=$(ls "${search_path}/${category}" | grep -E "^${filename}${dur_code_name}${dynamic_category}_[0-9]{3}.wav$" | tail -n 1 | sed -E "s/^.*_([0-9]{3}).wav$/\1/")
      if [[ $name_counter =~ ^0[0-9]+$ ]]; then
        # remove leading zeros if any
        name_counter=$(echo $name_counter | sed -E "s/^0+//")
      else
        name_counter=0
      fi
      name_counter=$((name_counter + 1))
      name_counter=$(printf "%03d" "$name_counter")
      new_filename="${filename}${dur_code_name}${dynamic_category}_${name_counter}.wav"
    fi
  fi

  new_filepath="${search_path}/${category}/${new_filename}"
  echo "Copying $file to $new_filepath"
  cp "$file" "$new_filepath"
done

echo ""
echo "Done!"
echo ""
echo "Summary:"
echo "--------"
echo ""
echo "Transient: $((transient_counter - 1))"
echo "Short: $((short_counter - 1))"
echo "Medium: $((medium_counter - 1))"
echo "Long: $((long_counter - 1))"
echo "Extended: $((extended_counter - 1))"
echo "Original File Count: ${#audio_files[@]}"
# its ok if this number is higher than the number of files, because some files might be in multiple categories
echo "Total Categorised: $(($transient_counter + $short_counter + $medium_counter + $long_counter + $extended_counter - 5))"
