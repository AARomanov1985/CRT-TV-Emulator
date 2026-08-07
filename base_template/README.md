# CRT TV Signal Emulation Base Template

![example](example.png)

Generic POSIX shell baseline engine (`tv.sh`) designed to batch-process video files through an `ffmpeg` DSP pipeline to simulate CRT display characteristics and audio hardware constraints.

## Core Architecture

* **Batch Processing**: Iterates through all `.avi`, `.mp4`, `.mkv`, and `.webm` files located in the script working directory.
* **Dynamic Multi-Track Audio Handling**: Queries stream count using `ffprobe`. Automatically splits generated audio interference and processes every audio track independently while maintaining channel mapping parity.
* **Directory Management**: Automatically initializes an `./out/` target directory and writes converted Matroska container outputs.



## Default Pipeline Parameters

### Video Processing Stage

* **Frame & Aspect**: Normalizes inputs to 768x576 (4:3 aspect ratio) with black borders.
* **Signal Degradation**: Applies dynamic temporal matrix noise (`noise=alls=20:allf=t+u`) and horizontal chroma phase offset (`chromashift=cbh=3:crh=-3`).
* **Optical Simulation**: Emulates spot defocus (`boxblur=2:1:0:0`), scanline raster grids (`drawgrid`), brightness/contrast transfer curves, and edge falloff (`vignette`).



### Audio Processing Stage

* **Downmixing**: Forces mono signal output (`aformat=channel_layouts=mono`) downsampled to 22,050 Hz.
* **Frequency Bandwidth**: Cuts low frequencies under 120 Hz and high frequencies above 3,800 Hz.
* **EQ & Noise**: Adds +5 dB equalization boost at 1,000 Hz and mixes in synthesized pink static generated via `anoisesrc`.



## Usage

Place the script in the input file directory and execute:
```sh
chmod +x tv.sh
./tv.sh

```