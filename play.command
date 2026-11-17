#!/bin/bash
set -eu

project_dir="$(cd -- "$(dirname -- "$0")" && pwd)"

start_game() {
    "$godot_bin" --headless --editor --path "$project_dir" --import --quit \
        --log-file "${TMPDIR:-/tmp}/ae4pa-import-$$.log"
    exec "$godot_bin" --path "$project_dir" "$@"
}

for godot_bin in \
    "/Applications/Godot.app/Contents/MacOS/Godot" \
    "$HOME/Downloads/Godot.app/Contents/MacOS/Godot"; do
    if [ -x "$godot_bin" ]; then
        start_game "$@"
    fi
done

if command -v godot >/dev/null 2>&1; then
    godot_bin="$(command -v godot)"
    start_game "$@"
fi

printf '%s\n' '未找到 Godot。请将 Godot.app 放入“应用程序”或“下载”文件夹后重试。' >&2
exit 1
