#!/bin/bash
# Lite: Rassvet-307 (40LK6B monochrome, luma-only tone).
# Usage: ./rassvet_307.sh <input> [output]
set -euo pipefail

CHASSIS="rassvet_307"
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/_common.sh"
lite_main "$@"
