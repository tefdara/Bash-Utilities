# bash-utilities

A collection of audio editing and organizational utilities for managing large numbers of files. Some of these use external libraries or tools suck as ffmpeg, sox etc. Look at the script for requirements or dependencies.

## Usage

To use these utilities, simply run the appropriate script from the command line. For example, to run the `batch_name.sh` script, navigate to the directory where the script is located and run:

```shell
./batch_name.sh
```

## Making Scripts Executable

Before you can run a script from the command line, you need to make sure that it is executable. To do this, you can use the `chmod` command. For example, to make the `batch_name.sh` script executable, navigate to the directory where the script is located and run:

```shell
chmod +x batch_name.sh
```

This will add the executable permission to the script. You can then run the script using the `./` prefix, as shown in the previous section.

## Aliases

If you want to create an alias for any of these scripts so that you can run them from anywhere in the terminal, you can do so by adding the following line to your shell configuration file (e.g. `~/.bashrc` or `~/.zshrc` or `~/.zprofile`):

```shell
alias renamefiles="bash ~/path/to/batch_name.sh"
```

Or use echo:

```shell
echo "alias renamefiles="bash ~/path/to/batch_name.sh"" >> ~/.zprofile && source ~/.zprofile
```

Replace `~/path/to` with the actual path to the directory where the script is located.

After adding the alias, you can run the script from anywhere in the terminal by simply typing:

```shell
renamefiles
```

Note that you will need to restart your terminal or run `source ~/.bashrc` (or `source ~/.zshrc`) for the alias to take effect.

## Contributing

If you find a bug or have a feature request, please open an issue or submit a pull request.

## License

These utilities are licensed under the GNU Genral Public License. See the [LICENSE](LICENSE) file for details.