# Find Silent Audio Files

This script uses ffmpeg to find audio files with mean volume below a certain threshold. It takes in the directory path as the first argument and the threshold as the second with `-t` or `--threshold`.

## Usage

```shell
silentsample path [-t threshold]
```

Example usage: 
```shell
silentsample /audioFolder -t -50
```

- `path`: Directory path of the audio files.
- `-t`: Define the threshold for silent detection. If not provided, the default is -40 dB.

## Requirements

- `ffmpeg` command-line utility for audio processing. You can install it using your system's package manager. For example, on Ubuntu, you can run `sudo apt-get install ffmpeg`. On macOS, you can install it using Homebrew: `brew install ffmpeg`.

## Supported File Formats

- WAV
- AIF
- AIFF
- FLAC
- MP3

If you need to add support for other formats, you can do so by adding the format extension to the `file_extensions` variable in the script.

## Moving Silent Audio Files

The script prompts the user to move the silent audio files to a directory named `Silent_Audio` in their home directory. If the directory doesn't exist, it will be created.
