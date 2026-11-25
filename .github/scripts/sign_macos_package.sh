#!/usr/bin/env bash
set -euo pipefail
umask 077

for name in MACOS_CERTIFICATE MACOS_CERTIFICATE_PASSWORD MACOS_SIGNING_IDENTITY \
  ASC_API_KEY_P8 ASC_API_KEY_ID ASC_API_ISSUER_ID; do
  if [[ -z "${!name:-}" ]]; then
    printf '::error::Missing %s in the macos-release environment. See docs/desktop-release.md.\n' "$name" >&2
    exit 1
  fi
done
if [[ "$MACOS_SIGNING_IDENTITY" != 'Developer ID Application: '* ]]; then
  echo '::error::MACOS_SIGNING_IDENTITY must name a Developer ID Application identity.' >&2
  exit 1
fi

unsigned=$1
distributable=$2
work=$(mktemp -d "$RUNNER_TEMP/macos-signing.XXXXXX")
keychain="$work/signing.keychain-db"
trap 'security delete-keychain "$keychain" 2>/dev/null || true; rm -rf "$work"' EXIT

printf '%s' "$MACOS_CERTIFICATE" | base64 -D > "$work/certificate.p12"
printf '%s' "$ASC_API_KEY_P8" | base64 -D > "$work/notary.p8"
keychain_password=$(openssl rand -hex 32)
security create-keychain -p "$keychain_password" "$keychain"
security set-keychain-settings -lut 3600 "$keychain"
security unlock-keychain -p "$keychain_password" "$keychain"
security import "$work/certificate.p12" -k "$keychain" -P "$MACOS_CERTIFICATE_PASSWORD" -T /usr/bin/codesign
security set-key-partition-list -S apple-tool:,apple: -s -k "$keychain_password" "$keychain" >/dev/null
identities=$(security find-identity -v -p codesigning "$keychain")
if ! grep -Fq "\"$MACOS_SIGNING_IDENTITY\"" <<< "$identities"; then
  echo '::error::The imported certificate does not provide the configured Developer ID Application identity.' >&2
  exit 1
fi

app_name='Monster Hotel.app'
ditto -x -k "$unsigned" "$work/unpacked"
app="$work/unpacked/$app_name"
bash .github/scripts/check_macos_bundle.sh "$app"

# The current GDScript export has a single Mach-O executable and no nested native code.
# If native plugins are added, sign those individually before signing the app.
codesign --force --timestamp --options runtime --sign "$MACOS_SIGNING_IDENTITY" --keychain "$keychain" "$app"
codesign --verify --deep --strict "$app"
signature=$(codesign --display --verbose=4 "$app" 2>&1)
grep -q '^Authority=Developer ID Application:' <<< "$signature"
grep -q 'flags=.*(runtime)' <<< "$signature"

submission="$work/notarization.zip"
result="$work/notarization.json"
ditto -c -k --sequesterRsrc --keepParent "$app" "$submission"
if ! xcrun notarytool submit "$submission" --key "$work/notary.p8" --key-id "$ASC_API_KEY_ID" \
  --issuer "$ASC_API_ISSUER_ID" --wait --timeout 30m --output-format json > "$result" ||
  ! jq -e '.status == "Accepted"' "$result" >/dev/null; then
  echo '::error::Apple notarization did not return Accepted.' >&2
  if submission_id=$(jq -er '.id // empty' "$result"); then
    xcrun notarytool log "$submission_id" --key "$work/notary.p8" --key-id "$ASC_API_KEY_ID" \
      --issuer "$ASC_API_ISSUER_ID" || true
  fi
  exit 1
fi
jq -r '"Notarization: \(.status) (\(.id))"' "$result"
xcrun stapler staple "$app"

mkdir -p "$(dirname "$distributable")"
ditto -c -k --sequesterRsrc --keepParent "$app" "$distributable"
ditto -x -k "$distributable" "$work/final"
final_app="$work/final/$app_name"
bash .github/scripts/check_macos_bundle.sh "$final_app"
codesign --verify --deep --strict "$final_app"
xcrun stapler validate "$final_app"
spctl --assess --type execute --verbose "$final_app"
