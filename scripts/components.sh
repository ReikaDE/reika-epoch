#!/bin/sh
# SPDX-FileCopyrightText: 2026 ReikaDE contributors
# SPDX-License-Identifier: MIT
#
# Prints the manifest rows (name kind license phase), optionally only the
# named components. Usage: components.sh ROOT [NAME...]
set -eu
here=$(cd "$(dirname "$0")/.." && pwd)
shift
grep -v '^[[:space:]]*\(#\|$\)' "$here/components.list" | while read -r name kind license phase; do
  if [ $# -eq 0 ]; then
    echo "$name $kind $license $phase"
  else
    for want in "$@"; do
      [ "$want" = "$name" ] && echo "$name $kind $license $phase"
    done
  fi
done
