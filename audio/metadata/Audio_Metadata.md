# Audio Metadata

If you do a lot of recordings and then chop them up and rename the files, sometime it helps to maintain certain type of information related to how this sound was made in the first place. This script adds metadata to all audio files in a given directory. The metadata includes the filename, sample rate, bit rate, duration, and any custom comments specified by the user.

## Requirements

- [ffmpeg] (https://ffmpeg.org/)
- [ffprobe] (https://ffmpeg.org/ffprobe.html)
- [mediainfo] (https://mediaarea.net/en/MediaInfo) (optional - if fforobe fails to get the stream data, mediainfo will be used)instead)

## Usage

```shell
Usage: ./amdt.sh [-c comment] [-d] [-i input_file] [-l] [-mt metadata_template] [-s] path

Example usage : amdt /audioFolder -c "This is a comment"

path: Directory path of the audio files.
-c: Optional comment to add to the metadata string. Can be used multiple times to add multiple comments.
-d: Disable default comment: source_file_name, source_sample_rate, source_bit_depth, source_channels, source_creation_date
-i: Specify a single file to process.
-l: Log the current comments in the metadata string.
-s: Show the available streams in the file, i.e. the audio streams containing the sample rate, bit depth, etc.
-mt: Specify a metadata template file. The script will use the template to generate the metadata string.
     he template file should be a text file with one line per comment with values separated by a colon.
     For variables that you would like to extract from the audio file, use the following format: {variable_name}
     Example:
     source_file_name: {source_file_name}
     Tip: you can override the default variable names. Note that if you redefine any of the default variables, the script will assume a custom config is being used and won't add any of the default comments:
     bit-depth: {bits_per_sample}
     To see the list of available variables, use the -s flag.
```

- `path`: The path to the directory containing the audio files.
- `-c comment`: Optional comment to add to the metadata string. Can be used multiple times to add multiple comments.
- `-l log`: Logs current comments in the metadata string.
- `-s stream`: Show all the streams in the file"
- `dd` : Disable default comments; source_file_name, source_sample_rate, source_bit_depth, source_channels, source_creation_date

## Output

The output files will be saved in the same directory as the input files, with the same filename and extension.

Each output file will have the following metadata:

- `source_file_name`: The filename or a custom name specified by the user.
- `source_sample_rate`: The sample rate of the input file.
- `source_bit_depth`: The bit depth of the input file.
- `source_channels`: The number of channels in the input file.
- `source_creation_date`: The creation date of the input file.
- Any custom comments specified by the user.

The information above is meant to preserve the original stats of the file if any of them change at some point.
## Examples

```shell
./amdt.sh /path/to/audio/files -c "Recorded on 2022-01-01" -c "Edited by John Doe"
```

This will add metadata to all audio files in the `/path/to/audio/files` directory, with two custom comments: "Recorded on 2022-01-01" and "Edited by John Doe".

Add a comment to all audio files in a directory:

```shell
amdt /path/to/audio/folder -c "This is a comment"
```

Disable default comments and add a custom comment:

```shell
amdt /path/to/audio/folder -dd -c "Custom comment"
```

Add metadata to a single file:

```shell
amdt -i /path/to/audio/file.wav -c "This is a comment"
```

Show the extractable data streams in an audio file:

```shell
amdt /path/to/audio/file.wav -s
```

Use a template to generate the metadata:

```shell
amdt /path/to/audio/folder -mt /path/to/metadata_template.txt
```


## Autocomplete

The script includes autocomplete for the input file. To enable autocomplete, add the following line to your shell profile:

```
complete -F _amdt_complete_input_file -o filenames -o nospace amdt.sh
```
