# Sound File Metadata

If you do a lot of recordings and then chop them up and rename the files, sometime it helps to maintain certain type of information related to how this sound was made in the first place. This script adds metadata to all audio files in a given directory. The metadata includes the filename, sample rate, bit rate, duration, and any custom comments specified by the user.

## Requirements

- `ffmpeg` (https://ffmpeg.org/)
- `ffprobe` (https://ffmpeg.org/ffprobe.html)

## Usage

```shell
./au_md.sh [-c comment] path
```

- `path`: The path to the directory containing the audio files.
- `-c comment`: Optional comment to add to the metadata string. Can be used multiple times to add multiple comments.

## Output

The output files will be saved in the same directory as the input files, with the same filename and extension.

Each output file will have the following metadata:

- `Source Recording`: The filename before the first `_` in the input filename.
- `Sample Rate`: The sample rate of the input file.
- `Bit Rate`: The bit rate of the input file.
- `Duration`: The duration of the input file.
- Any custom comments specified by the user.

## Examples

```shell
./au_md.sh /path/to/audio/files -c "Recorded on 2022-01-01" -c "Edited by John Doe"
```

This will add metadata to all audio files in the `/path/to/audio/files` directory, with two custom comments: "Recorded on 2022-01-01" and "Edited by John Doe".

```shell
./au_md.sh /path/to/audio/files
```

This will add metadata to all audio files in the `/path/to/audio/files` directory, without any custom comments.