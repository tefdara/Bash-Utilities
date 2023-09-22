# Trim Fade Reverse

This script uses SOX to trim silence, add fades, normalize, and rename audio files in a directory and its subdirectories. It takes in the directory path as the first argument.

## Requirements

- `sox` command-line utility for sound processing. You can install it using your system's package manager. For example, on Ubuntu, you can run `sudo apt-get install sox`.
- `find` command-line utility for searching directories.
- `mediainfo` command-line utility for getting audio file duration.

## Usage

```shell
trimfade path [-t audio_format] [--name new_file_name] [--rev] [-l preset] [--hpf highpass_filter_frequency]
```

Example usage: `trimfade /audioFolder -t mp3 --name bass_transient -l short --hpf 60`

- `path`: Directory path of the audio files.
- `-t`: Audio file type to process. Default is `wav`.
- `--name`: Provide a custom name for processed files. Default is the original name.
- `--rev`: Add this flag to reverse the audio.
- `-l`: Choose a length preset for trimming. Options are `long`, `short`, and `stich`. 
  - `long` applies a 100ms fade in and out.
  - `short` applies a 20ms fade in and out.
  - `stich` applies a 100ms fade in and out with no silence trimming. 
  - Default is `long`.
- `--hpf`: Define the highpass filter frequency. If not provided, the default is 40 Hz.

## Bash Shortcut

You can use `echo` to add it to `~/.zprofile` or `~/.bash_profile` or `~/.bashrc`, depending on your system.

```shell
echo "alias trimfade=\"bash ~/path-to-script/sox_trim_fade.sh\"" >> ~/.zprofile && source ~/.zprofile
```

## Output

The processed audio files will replace the original files in the specified directory path.

## Safety Check

The script prevents running in the home directory to avoid accidental file deletion.

