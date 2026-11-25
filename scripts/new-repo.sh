#!/bin/sh
# SPDX-FileCopyrightText: 2026 ReikaDE contributors
# SPDX-License-Identifier: MIT
#
# Creates a component repository from templates/common and templates/KIND.
# Placeholders replaced in file contents and names:
#   @NAME@        repository name (reika-comp)
#   @NAMESPACE@   C# root namespace (Reika.Comp)
#   @CRATE@       Rust crate name (reika_comp)
#   @LICENSE@     SPDX license expression
#   @YEAR@        current year
#   @SMITHAY_GIT@ @SMITHAY_REV@ @AVALONIA_VERSION@ @AVALONIA_WAYLAND_VERSION@
#   @NWAYLAND_VERSION@ @TMDS_DBUS_VERSION@ @DOTNET_SDK@   from pins.env
# Usage: new-repo.sh ROOT NAME KIND LICENSE
set -eu
root=$1 name=$2 kind=$3 license=$4
here=$(cd "$(dirname "$0")/.." && pwd)
# shellcheck source=SCRIPTDIR/../pins.env
. "$here/pins.env"

case $kind in rust|dotnet|assets) ;; *) echo "unknown kind: $kind" >&2; exit 2 ;; esac
[ -f "$here/templates/licenses/$license.txt" ] || { echo "no license text: templates/licenses/$license.txt" >&2; exit 2; }
dest=$root/$name
[ ! -e "$dest" ] || { echo "already exists: $dest" >&2; exit 1; }

# reika-comp -> Reika.Comp, xdg-desktop-portal-reika -> Xdg.Desktop.Portal.Reika
namespace=$(echo "$name" | awk -F- '{ for (i = 1; i <= NF; i++) printf "%s%s", (i > 1 ? "." : ""), toupper(substr($i, 1, 1)) substr($i, 2) }')
crate=$(echo "$name" | tr - _)
year=$(date +%Y)

mkdir -p "$dest"
cp -R "$here/templates/common/." "$here/templates/$kind/." "$dest/"
mkdir -p "$dest/LICENSES"
cp "$here/templates/licenses/$license.txt" "$dest/LICENSES/"
# Configuration and metadata files are CC0 in every repository (REUSE.toml).
cp "$here/templates/licenses/CC0-1.0.txt" "$dest/LICENSES/"

subst() {
  sed -e "s|@NAME@|$name|g" -e "s|@NAMESPACE@|$namespace|g" -e "s|@CRATE@|$crate|g" \
      -e "s|@LICENSE@|$license|g" -e "s|@YEAR@|$year|g" \
      -e "s|@SMITHAY_GIT@|$SMITHAY_GIT|g" -e "s|@SMITHAY_REV@|$SMITHAY_REV|g" \
      -e "s|@AVALONIA_VERSION@|$AVALONIA_VERSION|g" -e "s|@AVALONIA_WAYLAND_VERSION@|$AVALONIA_WAYLAND_VERSION|g" \
      -e "s|@NWAYLAND_VERSION@|$NWAYLAND_VERSION|g" -e "s|@TMDS_DBUS_VERSION@|$TMDS_DBUS_VERSION|g" \
      -e "s|@DOTNET_SDK@|$DOTNET_SDK|g"
}

# Rename paths containing placeholders (deepest first), then fill in contents.
find "$dest" -depth -name '*@*@*' | while read -r path; do
  mv "$path" "$(dirname "$path")/$(basename "$path" | subst)"
done
find "$dest" -type f ! -path "$dest/LICENSES/*" | while read -r file; do
  subst < "$file" > "$file.tmp" && mv "$file.tmp" "$file"
done

# A committed Cargo.lock from the start, so `--locked` builds work.
if [ "$kind" = rust ] && command -v cargo >/dev/null 2>&1; then
  cargo generate-lockfile --quiet --manifest-path "$dest/Cargo.toml"
fi

git -C "$dest" init --quiet --initial-branch=main
echo "created $dest ($kind, $license)"
