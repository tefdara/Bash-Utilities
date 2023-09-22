#!/bin/bash

# This script downloads a file from a URL and verifies its hash and GPG signature

# Bash shortcut -> curlvar
# You can use echo to add it to ~/.zprofile or ~/.bash_profile or ~/.bashrc, depending on your system
# echo "alias curlvar=\"bash ~/path-to-script/curl_var.sh\"" >> ~/.zprofile && source ~/.zprofile


usage() {
  echo "Usage: curlvar --url <url> --hash <hash> --sha <sha algorithm> --sigurl <signature file url>"
  echo
  echo "Example usage : trimfade /audioFolder --name bass_transient -l short -hpf 60"
  echo "--url: File url."
  echo "--hash: Expected hash."
  echo "--sha: For SHA256, SHA512, and MD5, you would pass 256, 512, and 1, respectively."
  echo "--sigurl: signature file url."
}

#!/bin/bash

# Initialize variables
FILE_URL=""
EXPECTED_HASH=""
SHA_ALGORITHM="256"
GPG_SIG_URL=""

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --url) FILE_URL="$2"; shift ;;
        --hash) EXPECTED_HASH="$2"; shift ;;
        --sha) SHA_ALGORITHM="$2"; shift ;;
        --sigurl) GPG_SIG_URL="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Check that all parameters were provided
if [[ -z "$FILE_URL" || -z "$EXPECTED_HASH" || -z "$SHA_ALGORITHM" || -z "$GPG_SIG_URL" ]]; then
    echo "Missing parameters! Usage: $0 --url <url> --hash <hash> --sha <sha algorithm> --sigurl <signature file url>"
    exit 1
fi

# Download the file
echo "Downloading file from $FILE_URL..."
curl --proto =https -LO $FILE_URL

# Download the GPG signature file
echo "Downloading signature file from $GPG_SIG_URL..."
curl --proto =https -LO $GPG_SIG_URL

# Choose the hash command based on the algorithm
if [ "$SHA_ALGORITHM" == "1" ]; then
    SHA_COMMAND="md5 -q $(basename $FILE_URL)"
    echo "Calculating hash using md5..."
else
    SHA_COMMAND="shasum -a $SHA_ALGORITHM $(basename $FILE_URL) | awk '{ print $1 }'"
    echo "Calculating hash using shasum -a $SHA_ALGORITHM..."
fi

# Calculate the hash of the downloaded file
ACTUAL_HASH=$(eval $SHA_COMMAND)

# Print the calculated hash
echo "Calculated hash: $ACTUAL_HASH"

# Verify the hash
if [ "$ACTUAL_HASH" != "$EXPECTED_HASH" ]; then
    echo "Hash does not match the expected hash: $EXPECTED_HASH"
    exit 1
fi

# Verify the GPG signature
echo "Verifying GPG signature..."
gpg --verify $(basename $GPG_SIG_URL) $(basename $FILE_URL)

if [ $? -eq 0 ]; then
    echo "GPG signature is good."
else
    echo "GPG signature is bad!"
    exit 1
fi

echo "File is good."


