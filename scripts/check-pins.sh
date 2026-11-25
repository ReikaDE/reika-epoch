#!/bin/sh
# SPDX-FileCopyrightText: 2026 ReikaDE contributors
# SPDX-License-Identifier: MIT
#
# Compares each checked-out component with pins.env:
# - Rust: every smithay source in Cargo.lock is ReikaDE/smithay at SMITHAY_REV.
# - .NET: Directory.Packages.props uses AVALONIA_VERSION, AVALONIA_WAYLAND_VERSION,
#   NWAYLAND_VERSION, and TMDS_DBUS_VERSION.
# - Forks: reports when the local fork branch differs from the pin.
# Usage: check-pins.sh ROOT
set -eu
root=$1
here=$(cd "$(dirname "$0")/.." && pwd)
# shellcheck source=SCRIPTDIR/../pins.env
. "$here/pins.env"
fail=0
bad() { echo "MISMATCH $1: $2"; fail=1; }

prop_version() { # file package
  sed -n "s/.*PackageVersion Include=\"$2\" Version=\"\([^\"]*\)\".*/\1/p" "$1" | head -n 1
}

"$here/scripts/components.sh" "$root" | while read -r name kind _ _; do
  dir=$root/$name
  [ -d "$dir" ] || continue
  case $kind in
    rust)
      [ -f "$dir/Cargo.lock" ] || continue
      sources=$(grep -A2 '^name = "smithay"$' "$dir/Cargo.lock" | sed -n 's/^source = "\(.*\)"$/\1/p' || true)
      for s in $sources; do
        case $s in
          "git+$SMITHAY_GIT"*"#$SMITHAY_REV") ;;
          *) bad "$name" "smithay source $s, expected $SMITHAY_GIT at $SMITHAY_REV" ;;
        esac
      done
      ;;
    dotnet)
      props=$dir/Directory.Packages.props
      [ -f "$props" ] || continue
      for pair in "Avalonia $AVALONIA_VERSION" "ReikaDE.Avalonia.Wayland $AVALONIA_WAYLAND_VERSION" \
                  "NWayland $NWAYLAND_VERSION" "Tmds.DBus.Protocol $TMDS_DBUS_VERSION"; do
        package=${pair% *} want=${pair#* }
        v=$(prop_version "$props" "$package")
        [ -z "$v" ] || [ "$v" = "$want" ] || bad "$name" "$package $v, expected $want"
      done
      ;;
    fork)
      case $name in
        smithay) want=$SMITHAY_REV ;;
        Avalonia) want=$AVALONIA_FORK_REV ;;
        *) continue ;;
      esac
      have=$(git -C "$dir" rev-parse --verify --quiet reika/main || true)
      [ "$have" = "$want" ] || echo "NOTE $name: reika/main is ${have:-missing}, pinned $want"
      ;;
  esac
done > "${TMPDIR:-/tmp}/reika-check-pins.$$"
cat "${TMPDIR:-/tmp}/reika-check-pins.$$"
if grep -q '^MISMATCH' "${TMPDIR:-/tmp}/reika-check-pins.$$"; then fail=1; fi
rm -f "${TMPDIR:-/tmp}/reika-check-pins.$$"
[ $fail -eq 0 ] && echo "pins: ok"
exit $fail
