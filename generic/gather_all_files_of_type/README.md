# File Gatherer

This script finds all files of a given format in a given folder and copies them into a new directory provided by the user. It takes in the format as the first argument, the source directory as the second, and the destination directory as the third (optional).

## Requirements

- `find` command-line utility for searching directories.

## Usage

```shell
./gather_files.sh -f format source_directory_path [destination_directory_path]
```

Example usage: `./gather_files.sh -f .png ~/Desktop ~/Desktop/destination`

- `-f`: file format to search for.
- `source_directory_path`: Directory path to search for files.
- `destination_directory_path`: Directory path to copy the files to. If not provided, a new directory will be created in the source directory.

## Safety Check

The script prevents running in the home directory to avoid accidental file deletion.

## Output

The script creates a new directory in the source directory (or uses the provided destination directory) and copies all files of the specified format to the new directory.

