#!/bin/bash
# Lite: Gorizont 51TC-412 (planar 51cm, MCR-403 decoder tone).
# Usage: ./gorizont_51tc412.sh <input> [output]
set -euo pipefail

CHASSIS="gorizont_51tc412"
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/_common.sh"
lite_main "$@"
