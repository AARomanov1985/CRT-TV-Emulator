# CRT TV Emulator

![strong_signal_color](chassis/daewoo_dtc20u1/strong_signal_color.png)

FFmpeg pipeline for end-to-end signal degradation, modeling analog video and audio through combined processing stages.

This models the complete physical hardware path as processing steps:

```
[Input Video] → [Signal / Tape Transport] → [Condition Vector] → [Display Chassis & Acoustics] → [Video Output]

```

## Prerequisites

* `bash` (4.0 or newer)
* `ffmpeg` built with standard video filter and audio processing libraries

## Usage

### Interactive Execution

```bash
chmod +x convert.sh
./convert.sh

```

Output files are written to an `out/` directory alongside the source using the naming pattern:
`<basename>_<signal>_<condition>_<chassis>.mkv`


## License

MIT