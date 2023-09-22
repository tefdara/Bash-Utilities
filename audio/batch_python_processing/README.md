# Batch Py

Batch Py is a bash script that runs a Python script on audio files in a directory and its subdirectories to extract descriptors.

## Usage

To use Batch Py, navigate to the directory containing the script and audio files you want to process and run the following command:

```shell
batchpy -s /path/to/python/script.py -p /path/to/audio/files -o "options"
```

### Options

- `-s, --script`: The path to the Python script you want to run on the audio files.
- `-p, --path`: The path to the directory containing the audio files you want to process.
- `-o, --options`: Optional arguments to pass to the Python script.

### Example

To run the Python script `my_script.py` on all `.wav`, `.aif`, and `.aiff` files in the directory `/path/to/audio/files` and its subdirectories, with the optional argument `--verbose`, run the following command:

```shell
batchpy -s /path/to/my_script.py -p /path/to/audio/files -o "--verbose"
```

