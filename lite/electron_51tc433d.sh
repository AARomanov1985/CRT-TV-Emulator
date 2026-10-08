#!/bin/bash
# Lite: Electron 51TC-433D (51LK2B tube, MCR-402 decoder tone).
# Usage: ./electron_51tc433d.sh <input> [output]
set -euo pipefail

CHASSIS="electron_51tc433d"
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/_common.sh"
lite_main "$@"
