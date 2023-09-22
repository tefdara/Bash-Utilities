# File Downloader with Hash and GPG Verification

This script downloads a file from a URL and verifies its hash and GPG signature. It takes in the file URL, expected hash, SHA algorithm, and signature file URL as command line arguments.

## Requirements

- `curl` command-line utility for downloading files.
- `gpg` command-line utility for verifying GPG signatures.
- Supported hash algorithms: SHA256, SHA512, and MD5.

## Usage

```shell
curlvar --url <url> --hash <hash> --sha <sha algorithm> --sigurl <signature file url>
```

Example usage: `curlvar --url https://example.com/file.zip --hash 1234567890abcdef --sha 256 --sigurl https://example.com/file.zip.sig`

- `--url`: File URL.
- `--hash`: Expected hash.
- `--sha`: For SHA256, SHA512, and MD5, you would pass 256, 512, and 1, respectively. Default is 256.
- `--sigurl`: Signature file URL.

## Output

The script downloads the file and signature file to the current directory and verifies the hash and GPG signature. If the hash and signature are valid, it prints "File is good." to the console.
