# CRT-TV Simulation

![example](base_template/example.png)

Deterministic FFmpeg signal processing scripts modeling hardware characteristics, phosphor dynamics, and acoustic output across various CRT television chassis.

## Prerequisites

* **FFmpeg** (v4.3+ compiled with `libx264` and filter graph support)
* **FFprobe** (for stream detection and channel count query)
* **POSIX-compliant Shell** (`sh`, `bash`, `zsh`)
* **Core Utilities**: `wc`, `tr`, `mkdir`, `eval`


## How To Use

1. Copy `convert.sh` from the target TV profile directory into your video directory:
2. Navigate to your video directory and execute: `chmod +x convert.sh && ./convert.sh`
3. Processed videos accumulate in `./out/`

## License

MIT