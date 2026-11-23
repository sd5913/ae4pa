#!/usr/bin/env bash
set -euo pipefail

version=4.7.2
release="Godot_v${version}-stable"
base="https://github.com/godotengine/godot/releases/download/${version}-stable"
templates="${release}_export_templates.tpz"
downloads="$RUNNER_TEMP/godot-downloads"
tools="$RUNNER_TEMP/godot-bin"

case "$(uname -s)" in
  Linux)
    editor="${release}_linux.x86_64"
    editor_sha256=cadd3204e728a35d3f13adb7fd0d7902636b79f6b95c40c265eb73b6c35329e4
    template=linux_release.x86_64
    data="$RUNNER_TEMP/godot-data"
    export XDG_DATA_HOME="$data"
    printf 'XDG_DATA_HOME=%s\n' "$data" >> "$GITHUB_ENV"
    template_dir="$data/godot/export_templates/$version.stable"
    ;;
  Darwin)
    editor="${release}_macos.universal"
    editor_sha256=c58a24e31d720be9d62f60cb5627c4e695fb72f21b0cfe1bc9ccaa9a3b3ba63e
    template=macos.zip
    template_dir="$HOME/Library/Application Support/Godot/export_templates/$version.stable"
    ;;
  *)
    echo 'Expected a Linux or macOS runner.' >&2
    exit 1
    ;;
esac

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

download_verified "$editor.zip" "$editor_sha256"
download_verified "$templates" f298490b8d44d934be425a5a65a51bf15f422428b229a06a6e11d9ffea248011

if [[ "$template" == macos.zip ]]; then
  ditto -x -k "$editor.zip" "$tools"
  cat > "$tools/godot" <<'WRAPPER'
#!/usr/bin/env bash
exec "$(dirname "$0")/Godot.app/Contents/MacOS/Godot" "$@"
WRAPPER
  chmod 0755 "$tools/godot"
else
  unzip -oq "$editor.zip" -d "$tools"
  install -m 0755 "$tools/$editor" "$tools/godot"
fi
unzip -oj "$templates" templates/version.txt "templates/$template" \
  templates/icudt_godot.dat -d "$template_dir"
test "$(cat "$template_dir/version.txt")" = "$version.stable"
test "$("$tools/godot" --headless --version)" = "$version.stable.official.ed1daf0bf"
printf '%s\n' "$tools" >> "$GITHUB_PATH"
