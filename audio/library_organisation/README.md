# Library Organizer

This script organizes audio files in a given directory based on their duration. It creates subdirectories for files that are shorter than a given threshold, and moves the files into the appropriate subdirectory.

## Dependencies

- `mediainfo`

## Usage

```shell
Usage: organize_audio directory_path [-name custom_name] [-trans transient_duration_ms] [-short short_duration_ms] [-long long_duration_ms]

directory_path: The directory path to search for audio files.
-name, --custom-name: Optional custom name to use as a prefix for the new file names.
-trans, --transient: Optional duration threshold in milliseconds for transient audio files. Defaults to 500ms.
-short, --short-duration: Optional duration threshold in milliseconds for short audio files. Defaults to 1000ms.
-long, --long-duration: Optional duration threshold in milliseconds for long audio files. Defaults to 5000ms.
```

## Examples

Organize all audio files in the current directory:

```shell
organize_audio .
```

Organize all audio files in a specific directory with custom name:

```shell
organize_audio /path/to/audio/folder -name "my_audio"
```

Organize all audio files in a specific directory with custom duration thresholds:

```shell
organize_audio /path/to/audio/folder -trans 500 -short 2000 -long 10000
```

## Safety Check

The script includes a safety check to prevent it from running in the home directory. This is to prevent accidental deletion of important files. If you try to run the script in the home directory, you will see an error message and the script will exit.



