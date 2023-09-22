GitHub Copilot: Sure, here's a sample README for the `batch_rename.sh` script:

# Batch File Renamer

This script renames audio files in a directory and its subdirectories. It takes in the directory path as the first argument.


## Requirements

- `find` command-line utility for searching directories.

## Usage

```shell
batchname directory_path [-name custom_name] [-append append_text]
```

Example usage: `batchname ~/Music/MyAlbum -name NewAlbum`

- `directory_path`: Directory path of the audio files.
- `-name`: Provide a custom name for the files. If not provided, the original name will be used.
  - You can use `%` in the custom name to enumerate the files.
  - Example: `batchname ~/Music/MyAlbum -name MyAlbum_%_Take` -> `MyAlbum_1_Take_1.wav`, `MyAlbum_2_Take_2.wav`, ...
- `-append`: Append text to the original name. If not provided, no text will be appended.
  - You can use `%` in the append text to enumerate the files.
  - Example: `batchname ~/Music/MyAlbum -append _remastered_%` -> `MyAlbum_remastered_1.wav`, `MyAlbum_remastered_2.wav`, ...


## Safety Check

The script prevents running in the home directory to avoid accidental file deletion.
