GitHub Copilot: Certainly! Here's a README file for the `au_cut.sh` script:

# Audio Segmentation

This script uses the `aubiocut` tool to cut an audio file into multiple segments based on a specified threshold and preset. It's just a shortcut to aubio cut so that quick segmentation can be done using some presets. 

## Requirements

- `aubiocut` tool (https://github.com/aubio/aubio)

## Usage

```shell
./au_cut.sh input_file [-t|--threshold threshold_value] [-p|--preset preset_number]
```

- `input_file`: The path to the input audio file.
- `-t|--threshold`: The threshold value used to detect silence. Default value is `0.5`.
- `-p|--preset`: The preset number to use. Valid values are `1` to `7`. Default value is `1`.

## Presets

The following presets are available:

1. `-B 4096 -H 128 -O mkl`
2. `-B 4096 -H 128 -O specdiff`
3. `-B 4096 -H 1024 -O complex`
4. `-O phase`
5. `-B 2048 -H 128 -O specdiff`
6. `-B 1024 -H 1024 -O hfc`
7. `-B 1024 -H 128`

## Output

The output files will be saved in a directory with the same name as the input file, in the same directory as the input file.

Each output file will be named `input_file_XX.wav`, where `XX` is a two-digit number representing the segment number.

## Examples

```shell
./au_cut.sh input_file.wav -t 0.3 -p 2
```

This will cut the `input_file.wav` file into segments using the `specdiff` preset with a threshold of `0.3`.

```shell
./au_cut.sh input_file.wav -p 5
```

This will cut the `input_file.wav` file into segments using the `specdiff` preset with the default threshold of `0.5`.