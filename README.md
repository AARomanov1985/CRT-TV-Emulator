# CRT TV Emulator

![strong\_signal\_color](chassis/daewoo_dtc20u1/strong_signal_color.png)

FFmpeg pipeline for end-to-end signal degradation, modeling analog video and audio through combined processing stages.

This models the complete physical hardware path as processing steps:

```
[Input Video] → [Signal / Media] → [Condition Vector] → [Player / Deck] → [Display Chassis & Acoustics] → [Video Output]
```

Sources:

- **TV** (`tv/`) — broadcast reception quality (strong/weak, color/BW)

- **VHS** (`vhs/`) — cassette hardware, plus a tape condition (`vhs_cond/`), played on a deck (`vhs_player/`, e.g. budget Funai vs JVC S7600 TBC)

- **DVD** (`dvd/`) — a disc model, played on a DVD deck (`dvd_player/`) that also carries the output connection character (composite vs component)

## Prerequisites

- `bash` (4.0 or newer)

- `ffmpeg` built with standard video filter and audio processing libraries

## Usage

### Interactive Execution

```
chmod +x convert.sh
./convert.sh
```

### Non interactive:

```
printf '1\n3\n5\n/path/to/clip.mp4\n' | ./convert.sh
```

Output files are written to an `out/` directory alongside the source using the naming pattern: `<basename>_<source>[_<condition>]_<player>_<chassis>.mkv`

## Lite

`lite/` contains simple per-chassis scripts — one per set in `chassis/`
(daewoo_dtc20u1, electron_51tc433d, funai_tv2000mk7, goldstar_ck20e40,
gorizont_51tc412, gorizont_736, junost_402b, junost_406, philips_gr1ax,
photon_51tc408d, rassvet_307, rubin_51tc, samsung_cs2173, sony_kv_m2180).

Video is the full chassis path: 400px high + tube blur,
EQ, white-point tint, shadow mask, tone curves and vignette. Only signal
stages (noise/ghost/chroma-shift) stay out.
Audio is the chassis speaker band + EQ with a pink-noise bed.
Each script sources its `chassis/*/filter.sh`, so tone stays in one place.

Usage: `./lite/sony_kv_m2180.sh <input> [output]` — keeps all audio tracks and subtitles.

`LITE_ULTRA=1` drops blur/mask/vignette: tone only (output gets a `u` suffix mark).

## License

MIT

