#!/usr/bin/env bash
set -euo pipefail

version=4.7.2
release="Godot_v${version}-stable"
base="https://github.com/godotengine/godot/releases/download/${version}-stable"
templates="${release}_export_templates.tpz"
downloads="$RUNNER_TEMP/godot-downloads"
tools="$RUNNER_TEMP/godot-bin"

editor="${release}_linux.x86_64"
data="$RUNNER_TEMP/godot-data"
export XDG_DATA_HOME="$data"
printf 'XDG_DATA_HOME=%s\n' "$data" >> "$GITHUB_ENV"
template_dir="$data/godot/export_templates/$version.stable"

mkdir -p "$downloads" "$tools" "$template_dir"
cd "$downloads"
download_verified() {
  local asset=$1 checksum=$2
  if [[ ! -f "$asset" ]]; then
    curl --fail --location --silent --show-error --retry 3 "$base/$asset" --output "$asset.part"
    mv "$asset.part" "$asset"
  fi
  printf '%s  %s\n' "$checksum" "$asset" | shasum -a 256 --check
}

download_verified "$editor.zip" cadd3204e728a35d3f13adb7fd0d7902636b79f6b95c40c265eb73b6c35329e4
download_verified "$templates" f298490b8d44d934be425a5a65a51bf15f422428b229a06a6e11d9ffea248011

unzip -oq "$editor.zip" -d "$tools"
install -m 0755 "$tools/$editor" "$tools/godot"
unzip -oj "$templates" templates/version.txt templates/linux_release.x86_64 \
  templates/macos.zip templates/icudt_godot.dat -d "$template_dir"
test "$(cat "$template_dir/version.txt")" = "$version.stable"
test "$("$tools/godot" --headless --version)" = "$version.stable.official.ed1daf0bf"
printf '%s\n' "$tools" >> "$GITHUB_PATH"
