# Library Organizer

This script organizes audio files in a given directory based on their duration. It creates subdirectories for files that are shorter than a given threshold, and moves the files into the appropriate subdirectory.

## Dependencies

- `mediainfo`

## Usage

```shell
./au_order.sh directory_path ['-name' custom_name] ['-fl' | '-flicker' flicker_duration_ms] ['-spark' spark_duration_ms] ['-transient' transient_duration_ms] ['-sw' | '-swift' swift_duration_ms] ['-short' short_duration_ms] ['-long' long_duration_ms] ['-ct' | '-continuous' continuous_duration_ms
```

## Options
- `path`: The path to the directory containing the audio files. This is the required argument 0 and has no flag.
- `-name`: Specify a custom name for the output files.
- `-fl` or `-flicker`: Specify the maximum duration for the 'flicker' category.
- `-spark`: Specify the maximum duration for the 'spark' category.
- `-transient`: Specify the maximum duration for the 'transient' category.
- `-sw` or `-swift`: Specify the maximum duration for the 'swift' category.
- `-short`: Specify the maximum duration for the 'short' category.
- `-long`: Specify the maximum duration for the 'long' category.
- `-ct` or `-continuous`: Specify the maximum duration for the 'continuous' category.

## Default Duration Values

- `Flicker`: 0-150ms
- `Spark`: 150-300ms
- `Transient`: 300-500ms
- `Swift`: 500-1000ms
- `Short`: 1000-2000ms
- `Average`: 2000-5000ms
- `Long`: 5000-10000ms
- `Continuous`: 10000ms+


## Examples

Organize all audio files in the current directory:

```shell
organize_audio ~/audio
```

Organize all audio files in a specific directory with custom name:

```shell
organize_audio /path/to/audio/folder -name "my_audio"
```

Organize all audio files in a specific directory with custom duration thresholds:

```shell
organize_audio /path/to/audio/folder -fl 100 -spark 200 -transient 300 -sw 400 -short 500 
```

## Safety Check

The script includes a safety check to prevent it from running in the home directory. This is to prevent accidental deletion of important files. If you try to run the script in the home directory, you will see an error message and the script will exit.

## License
GPLv3

