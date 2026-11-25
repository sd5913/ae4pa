#!/usr/bin/env bash
set -euo pipefail

app=$1
plist="$app/Contents/Info.plist"
plutil -lint "$plist"
test "$(plutil -extract CFBundlePackageType raw -o - "$plist")" = APPL
test "$(plutil -extract CFBundleIdentifier raw -o - "$plist")" = io.github.sd5913.ae4pa
executable=$(plutil -extract CFBundleExecutable raw -o - "$plist")
binary="$app/Contents/MacOS/$executable"
test -f "$binary" && test -x "$binary"
test -s "$app/Contents/Resources/$executable.pck"
architectures=$(lipo -archs "$binary")
case "$architectures" in
  'x86_64 arm64'|'arm64 x86_64') printf 'Universal 2 executable: %s\n' "$architectures" ;;
  *) printf 'Unexpected executable architectures: %s\n' "$architectures" >&2; exit 1 ;;
esac
