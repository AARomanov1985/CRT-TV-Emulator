#!/bin/bash
# Lite: Photon 51TC-408D (51LK2B, MCR-402 decoder tone).
# Usage: ./photon_51tc408d.sh <input> [output]
set -euo pipefail

CHASSIS="photon_51tc408d"
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/_common.sh"
lite_main "$@"
