# CRT Signal Emulator Suite

Deterministic FFmpeg processing modeling CRT television hardware: signal
reception characteristics, phosphor dynamics, scanline rasterization, and
speaker acoustics across various chassis.

One interactive script, one signal source, one TV, one pipeline.

## Prerequisites

* **FFmpeg** (v4.3+ compiled with `libx264` and filter graph support)
* **FFprobe** (for stream detection and channel count query)
* **POSIX-compliant Shell** (`sh`, `bash`, `zsh`)
* **Core Utilities**: `wc`, `tr`, `mkdir`, `eval`, `awk`, `sed`, `grep`

## How To Use

Run the interactive chooser:

```
chmod +x convert.sh
./convert.sh
```

1. Pick a signal source: `1` TV broadcast signal or `2` VHS cassette.
2. Pick a signal (reception quality / tape wear).
3. Pick a TV chassis.
4. Pick the path to a single video file or a directory of
   `.avi`/`.mp4`/`.mkv`/`.webm` files (or pass it as the first CLI argument).

Processed videos are written to `out/` next to the source video(s), as
`<name>_<signal>_<chassis>.mkv`. For a directory of inputs this is
`<input_dir>/out/`; for a single file it's the file's folder.

Non-interactive example (broadcast -> weak B/W signal -> Funai chassis):

```
printf '1\n3\n5\n/path/to/clip.mp4\n' | ./convert.sh
```

## Filter bank

The tool is a composable filter bank. Each fragment is a shell file that only
sets variables; `convert.sh` loads one signal-source fragment and one chassis
fragment, and `lib/engine.sh` merges them into a single FFmpeg filter graph.

```
lib/engine.sh    fragment loader + pipeline assembler
chassis/*        TV display + speaker path per model
tv/              broadcast reception degradation
vhs/             tape playback degradation
```

## License

MIT