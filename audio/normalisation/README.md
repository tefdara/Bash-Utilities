# Batch Normalise Audio Files

This script normalizes audio files in a directory and its subdirectories. It takes in the directory path as the first argument and the gain as the second with `-g` or `--gain`.

## Usage

```shell
normaudio path [-g gain]
```

Example usage: `normaudio /audioFolder -g -2`

- `path`: Directory path of the audio files.
- `-g`: Define the gain for normalization. If not provided, the default is -3 dB.


## Requirements

- `sox` command-line utility for sound processing. You can install it using your system's package manager. For example, on Ubuntu, you can run `sudo apt-get install sox`.

## Supported File Formats

- WAV
- AIF
- AIFF
- FLAC
- MP3
- M4A
- AAC

If you need to add support for other formats, you can do so by adding the format extension to the `file_extensions` variable in the script.