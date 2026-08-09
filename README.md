# CRT TV Emulator

![strong_signal_color](chassis/daewoo_dtc20u1/strong_signal_color.png)

FFmpeg pipeline for end-to-end signal degradation, modeling analog video and audio through combined processing stages.

This models the complete physical hardware path as processing steps:

```
[Input Video] → [Signal / Media] → [Condition Vector] → [Player / Deck] → [Display Chassis & Acoustics] → [Video Output]

```

Sources:

* **TV** (`tv/`) — broadcast reception quality (strong/weak, color/BW)
* **VHS** (`vhs/`) — cassette hardware, plus a tape condition (`vhs_cond/`),
  played on a deck (`vhs_player/`, e.g. budget Funai vs JVC S7600 TBC)
* **DVD** (`dvd/`) — a disc model, played on a DVD deck (`dvd_player/`) that
  also carries the output connection character (composite vs component)

## Prerequisites

* `bash` (4.0 or newer)
* `ffmpeg` built with standard video filter and audio processing libraries

## Usage

### Interactive Execution

```bash
chmod +x convert.sh
./convert.sh
```

### Non interactive:
```
printf '1\n3\n5\n/path/to/clip.mp4\n' | ./convert.sh
```

Output files are written to an `out/` directory alongside the source using the naming pattern:
`<basename>_<source>[_<condition>]_<player>_<chassis>.mkv`


## License

MIT