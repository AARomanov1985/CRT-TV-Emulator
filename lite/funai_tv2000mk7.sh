#!/bin/bash
# Lite: Funai TV-2000MK7 (20in shadow mask, single-chip decoder tone).
# Usage: ./funai_tv2000mk7.sh <input> [output]
set -euo pipefail

CHASSIS="funai_tv2000mk7"
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/_common.sh"
lite_main "$@"
