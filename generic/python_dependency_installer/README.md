# Python Dependency Installation

This script automatically installs Python dependencies from a `requirements.txt` file.

## Requirements

1. Python
2. Pip

## Usage

1. Ensure you have a `requirements.txt` file in your project directory with the necessary Python packages listed.
2. Download the `install_deps.sh` script to your project directory.
3. Make the script executable:
    ```bash
    chmod +x install_deps.sh
    ```
4. Run the script:
    ```bash
    ./install_deps.sh
    ```

## Example `requirements.txt`

Your `requirements.txt` file should list the Python packages you want to install. Here's an example:

```
flask==1.1.2
requests==2.25.1
scikit-learn>=1.3.0
scipy>=1.11.2
```

Each line specifies a package and optionally a version. You can specify exact versions (as above) or use version specifiers like `>=`, `<=`, etc.

## Troubleshooting

1. **pip not found**: Make sure `pip` is installed. You might need to install or update it.
2. **requirements.txt not found**: Ensure that the `requirements.txt` file exists in the same directory as the script.
