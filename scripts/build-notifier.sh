#!/bin/bash
# Builds "LIFX Menu Bar.app", a tiny helper that shows the plugin's notifications
# with a lightbulb icon instead of SwiftBar's. Without it, the plugin falls back
# to sending notifications through SwiftBar.
#
# Requires the Xcode command line tools:  xcode-select --install
# Usage:   ./scripts/build-notifier.sh          build build/LIFX Menu Bar.app
#          ./scripts/build-notifier.sh --icon   also redraw notifier/AppIcon.icns from icons/lightbulb.svg

set -euo pipefail
cd "$(dirname "$0")/.."

command -v swiftc >/dev/null || { echo "swiftc not found — run: xcode-select --install"; exit 1; }

if [ "${1:-}" = "--icon" ]; then
  tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
  swift notifier/make-icon.swift "$tmp/AppIcon.iconset"
  iconutil -c icns "$tmp/AppIcon.iconset" -o notifier/AppIcon.icns
  echo "Updated notifier/AppIcon.icns"
fi

APP="build/LIFX Menu Bar.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp notifier/Info.plist "$APP/Contents/"
cp notifier/AppIcon.icns "$APP/Contents/Resources/"
swiftc -O notifier/main.swift -o "$APP/Contents/MacOS/lifx-notifier"
codesign --force --sign - "$APP" >/dev/null 2>&1   # ad-hoc signature, needed for notifications

# Let macOS pick up the app's name and icon right away.
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP" || true

echo "Built $APP"
