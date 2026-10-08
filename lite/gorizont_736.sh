#!/bin/bash
# Lite: Gorizont 736/D (61LK3C flagship tone, wide speaker band).
# Usage: ./gorizont_736.sh <input> [output]
set -euo pipefail

CHASSIS="gorizont_736"
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/_common.sh"
lite_main "$@"
