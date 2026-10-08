#!/bin/bash
# Lite: Junost 402B (31LK4B monochrome, luma-only tone).
# Usage: ./junost_402b.sh <input> [output]
set -euo pipefail

CHASSIS="junost_402b"
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/_common.sh"
lite_main "$@"
