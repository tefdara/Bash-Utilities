# Audio Library Triming Tool

This script finds all audio files in a given folder and deletes them if they are shorter than a given threshold.

## Dependencies

- `find`
- `mediainfo`

## Usage

```shell
Usage: audel [-t threshold] [path]

path: Optional directory path to search for audio files. Defaults to the current directory.
-t, --threshold: Optional threshold in milliseconds. Audio files shorter than this threshold will be deleted. Defaults to 100ms.
```

## Examples

Delete all audio files shorter than 500ms in the current directory:

```shell
audel . -t 500
```

Delete all audio files shorter than 1 second in a specific directory:

```shell
audel -t 1000 /path/to/audio/folder
```

## Safety Check

The script includes a safety check to prevent it from running in the home directory. This is to prevent accidental deletion of important files. If you try to run the script in the home directory, you will see an error message and the script will exit.


