#!/bin/bash
# Lite: Samsung CS-2173 (KS1A one-chip, hot budget tone).
# Usage: ./samsung_cs2173.sh <input> [output]
set -euo pipefail

CHASSIS="samsung_cs2173"
. "$(CDPATH= cd -- "$(dirname "$0")" && pwd)/_common.sh"
lite_main "$@"
