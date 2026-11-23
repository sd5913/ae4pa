#!/usr/bin/env bash
set -euo pipefail

platform=$1
output="$RUNNER_TEMP/desktop"
packages="$RUNNER_TEMP/desktop-packages"
verifier="$RUNNER_TEMP/pack-check"
mkdir -p "$output" "$packages" "$verifier"
printf 'config_version=5\n' > "$verifier/project.godot"
cp .github/scripts/check_desktop_pack.gd "$verifier/"
source_dir=$PWD

run_godot() {
  local log=$1
  shift
  godot --headless "$@" 2>&1 | tee "$RUNNER_TEMP/$log.log"
  if grep -E '^(SCRIPT )?ERROR:' "$RUNNER_TEMP/$log.log"; then
    return 1
  fi
}

run_godot import --path . --editor --import --quit
case "$platform" in
  linux)
    game=MonsterHotel.x86_64
    pck=MonsterHotel.pck
    run_godot export --path . --export-release 'Linux x86-64' "$output/$game"
    test -s "$output/$game"
    chmod 0755 "$output/$game"
    test -s "$output/$pck"
    (cd "$output" && zip -q -6 "$packages/monster-hotel-linux-x86_64.zip" "$game" "$pck")
    pack="$output/$pck"
    ;;
  macos)
    app='Monster Hotel.app'
    archive="$packages/monster-hotel-macos-universal-unsigned.zip"
    run_godot export --path . --export-release 'macOS Universal' "$output/$app"
    mkdir -p "$output/review" "$output/extracted"
    printf '%s\n' 'macOS review build. Its ad hoc signature is for local testing only. No Developer ID signature or notarization.' \
      'Use the notarized GitHub Release for normal Gatekeeper installation.' \
      > "$output/review/UNSIGNED-REVIEW.txt"
    mv "$output/$app" "$output/review/"
    ditto -c -k --sequesterRsrc --keepParent "$output/review/$app" "$archive"
    (cd "$output/review" && zip -q "$archive" UNSIGNED-REVIEW.txt)
    ditto -x -k "$archive" "$output/extracted"
    test -s "$output/extracted/UNSIGNED-REVIEW.txt"
    bash .github/scripts/check_macos_bundle.sh "$output/extracted/$app"
    codesign --verify --deep --strict "$output/extracted/$app"
    executable=$(plutil -extract CFBundleExecutable raw -o - "$output/extracted/$app/Contents/Info.plist")
    pack="$output/extracted/$app/Contents/Resources/$executable.pck"
    ;;
  *) printf 'Unknown desktop platform: %s\n' "$platform" >&2; exit 1 ;;
esac

run_godot pack-check --path "$verifier" --script res://check_desktop_pack.gd -- "$pack" "$source_dir"
