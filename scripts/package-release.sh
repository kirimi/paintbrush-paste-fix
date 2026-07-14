#!/bin/sh

set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
APP="$ROOT/dist/Paintbrush Paste Fix.app"
ARCHIVE="$ROOT/dist/Paintbrush-Paste-Fix.zip"

sh "$ROOT/scripts/package-app.sh"
ditto \
    -c \
    -k \
    --norsrc \
    --noextattr \
    --noqtn \
    --noacl \
    --keepParent \
    "$APP" \
    "$ARCHIVE"

echo "$ARCHIVE"
