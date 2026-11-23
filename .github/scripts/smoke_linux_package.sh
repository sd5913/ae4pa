#!/usr/bin/env bash
set -euo pipefail

archive=$1
package=$(mktemp -d "$RUNNER_TEMP/linux-package.XXXXXX")
trap 'rm -rf "$package"' EXIT
unzip -q "$archive" -d "$package"
cd "$package"

test -s MonsterHotel.pck
test -x MonsterHotel.x86_64
file MonsterHotel.x86_64 | grep -E 'ELF 64-bit.*x86-64'

for language in zh_CN en; do
  profile="$package/$language"
  export XDG_CONFIG_HOME="$profile/config" XDG_DATA_HOME="$profile/data" XDG_CACHE_HOME="$profile/cache"
  mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_CACHE_HOME"
  if [[ "$language" == en ]]; then
    user_data="$XDG_DATA_HOME/godot/app_userdata/Monster Hotel"
    mkdir -p "$user_data"
    printf '[ui]\nlanguage="en"\n' > "$user_data/language.cfg"
  fi
  log="$RUNNER_TEMP/linux-launch-$language.log"
  timeout 90s ./MonsterHotel.x86_64 --headless --quit-after 60 2>&1 | tee "$log"
  grep -F 'Godot Engine v4.7.2.stable.official.ed1daf0bf' "$log"
  if grep -E '^(SCRIPT )?ERROR:' "$log"; then
    exit 1
  fi
  printf 'Exported Linux game started with the %s profile.\n' "$language"
done
