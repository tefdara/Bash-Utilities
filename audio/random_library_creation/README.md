# Random Audio Library Creator

This script picks random audio files from a directory and its subdirectories and creates a new library with the selected files. It takes in the directory path as the first argument.

## Requirements

- `find` command-line utility for searching directories.
- `mediainfo` command-line utility for getting audio file duration. You can install it using your system's package manager. For example, on Ubuntu, you can run `sudo apt-get install mediainfo`. On macOS, you can install it using Homebrew: `brew install mediainfo`.

## Usage

```shell
randaulib directory_path [-n num_files_to_pick] [-d max_duration_in_milliseconds] [-f folder_match]
```

Example usage: `randaulib /audioFolder -n 5 -d 10000 -f "jazz"`

- `directory_path`: Directory path of the audio files.
- `-n`: Define the number of files to pick from each folder. If not provided, the default is 1.
- `-d`: Define the maximum duration in milliseconds for the selected files. If not provided, all files will be considered.
- `-f`: Define a folder match pattern to filter the directories to search for audio files. If not provided, all directories will be searched.

## Output

The selected audio files will be copied to a new folder named `Random_Audio_Files` in the specified directory path.

