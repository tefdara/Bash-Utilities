# Library Organizer
This script organizes audio files based on their duration and intensity. It categorizes audio files into five categories: Transient, Short, Medium, Long, and Extended. The script also categorizes files based on their intensity, using classical music dynamics.

## Usage

```shellscript
./au_order.sh directory_path [-name custom_name] [-transient transient_duration_ms] [-short short_duration_ms] [-medium medium_duration_ms] [-long long_duration_ms] [-ppp ppp_threshold] [-pp pp_threshold] [-p p_threshold] [-mp mp_threshold] [-mf mf_threshold] [-f f_threshold] [-ff ff_threshold]
```

## Requirements

- `sox`
- `mediainfo`
- `bc`

## Usage

```shell
./au_order.sh directory_path [-name custom_name] [-transient transient_duration_ms] [-short short_duration_ms] [-medium medium_duration_ms] [-long long_duration_ms] [-ppp ppp_threshold] [-pp pp_threshold] [-p p_threshold] [-mp mp_threshold] [-mf mf_threshold] [-f f_threshold] [-ff ff_threshold]
```

## Options
- `path`: The path to the directory containing the audio files. This is the required argument 0 and has no flag.
- `-name`: Specify a custom name for the output files.
- `-transient`, `-short`, `-medium`, `-long`: Duration thresholds for each category in milliseconds.
- `-ppp`, `-pp`, `-p`, `-mp`, `-mf`, `-f`, `-ff`: Intensity thresholds for each category in dB.


## Default Values

- `Transient`: 0-300ms
- `Short`: 300-1000ms
- `Medium`: 1000-2500ms
- `Long`: 5000-10000ms
- `Extended`: 10000ms+

- `ppp`: -30 to -25 dB
- `pp`: -25 to -20 dB
- `p`: -20 to -15 dB
- `mp`: -15 to -10 dB
- `mf`: -10 to -5 dB
- `f`: -5 to 0 dB
- `ff`: 0 to 5 dB


## Examples

Organize audio files in the current directory:

```shell
organize_audio ~/audio
```

Organize audio files in a specific directory with custom name:

```shell
organize_audio /path/to/audio/folder -name "my_audio"
```

Organize all audio files in a specific directory with custom duration thresholds:

```shell
organize_audio /path/to/audio/folder -transient 0 -short 500 -medium 1000 -long 5000
```

Organize all audio files in a specific directory with custom intensity thresholds:

```shell
organize_audio /path/to/audio/folder -ppp -35 -pp -30 -p -25 -mp -20 -mf -15 -f -10 -ff -5
```

## Safety Check

The script includes a safety check to prevent it from running in the home directory. This is to prevent accidental deletion of important files. If you try to run the script in the home directory, you will see an error message and the script will exit.


## Output

The script creates new directories for each category in the input directory and copies the categorized files into the appropriate directories. The copied files are renamed with the format `fileName_durationCategory_dynamicsCategory_ID.extension`. For example, a file named `my_audio.wav` with a duration of 200ms and an intensity of -25dB will be renamed to `my_audio_S_p_001.wav` and copied to the `Short` directory.


