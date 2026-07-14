#!/bin/sh

set -eu

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
APP="$ROOT/dist/Paintbrush Paste Fix.app"
CONTENTS="$APP/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

swift build \
    --package-path "$ROOT" \
    -c release \
    --arch arm64 \
    --arch x86_64 \
    --disable-sandbox
mkdir -p "$MACOS" "$RESOURCES"
cp "$ROOT/.build/apple/Products/Release/PaintbrushPasteFix" "$MACOS/PaintbrushPasteFix"
cp "$ROOT/Assets/AppIcon.icns" "$RESOURCES/AppIcon.icns"
cp "$ROOT/App/Info.plist" "$CONTENTS/Info.plist"
codesign --force --sign - "$APP"

echo "$APP"
