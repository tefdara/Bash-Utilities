# Group Different Formats Of The Same File

This script groups files with the same name but different extensions in a new directory. It takes in the source directory as the first argument. The source extension is optional and if not provided, the script will use wav as the default. In essense, this script will find any other formats of a given file if they have the same name. 

The target directory is optional and if not provided, the source directory will be used to perform the search. The new directory is where the script will move the files to. If not provided, the script will create a new directory with the source file name one level up from the source directory.

## Usage

```shell
./group_files source_directory [-ex source_extension] [-t target_directory] [-nd new_directory]
```

## Options

- `-ex`: The source extension. Default is `wav`.
- `-t`: The target directory to look for other formats. Default is the same as the source directory.
- `-nd`: The new directory to move files to. Default is a new directory with the source file name, one level up from the source directory.

## Example

```shell
./group_files /path/to/source/directory -ex mp3 -t /path/to/target/directory -nd /path/to/new/directory
```

This will group all files with the `mp3` extension in the `/path/to/source/directory` directory and move them to the `/path/to/new/directory` directory. If there are files with the same name but other formats in the `/path/to/target/directory` directory, they will also be moved to the new directory.