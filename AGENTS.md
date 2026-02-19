# Repository Guidelines

## Project Structure & Module Organization
This repo is a collection of personal utility scripts and small tools. Key areas:
- `exiftools/` and `exiftool_v2/`: Bash scripts for image metadata, renaming, conversion, and video helpers.
- `ComfyUI_tools/`: Preview processing, video helpers, and a small Python server (`server/save_image.py`).
- `extension/`: A browser extension (manifest + JS/CSS) for automation.
- Root scripts like `initBash.sh`, `getDevServerAddress.sh` provide setup helpers.

## Build, Test, and Development Commands
There is no centralized build system or test runner. Scripts are executed directly.
- `bash exiftools/run.sh /path/to/images`: Interactive image toolkit (rename, crop, watermark, video).
- `bash exiftools/make-video.sh /path/to/images`: Create a video from image sequences.
- `bash ComfyUI_tools/bin/run.sh`: Start the save-image server and preview processor.
- `bash exiftool_v2/convert.sh /path/to/dir`: Convert and parse EXIF metadata.

Dependencies used by scripts include `bash`, `ffmpeg`, `exiftool`, `jq`, `python3`, and optionally `bun` and `fzf`. Install as needed for the scripts you run.

## Coding Style & Naming Conventions
- Indentation is 2 spaces in shell and JavaScript files.
- Shell scripts target `bash` and are named in `kebab-case` (for example `make-video.sh`).
- JavaScript uses semicolons and double quotes; keep functions small and focused.

## Testing Guidelines
No automated test framework or coverage targets are present. Validate changes manually by running the relevant scripts and confirming expected output files and logs.

## Commit & Pull Request Guidelines
Git history follows a lightweight Conventional Commit pattern: `feat:`, `fix:`, `chore:`, `refactor:`, `tweak:`, `update:`. Use the same prefixes for clarity.
For PRs, include:
- A concise summary of what scripts changed and why.
- Example command(s) used to validate (for example `bash exiftools/run.sh ./samples`).
- Any notable environment assumptions (macOS tools like `caffeinate`, external binaries).

## Agent-Specific Instructions
Keep changes minimal and script-focused. Prefer editing existing scripts over adding new helpers unless necessary.
