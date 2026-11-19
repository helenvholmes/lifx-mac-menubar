#!/bin/bash
# Regenerates the icon block in lifx.30s.sh from the SVGs in icons/.
#
# Each icons/<name>.svg becomes a variable I_<name> (dashes become underscores),
# rendered as a 32×32 px PNG marked @2x (144 dpi), so it shows at 16pt in the menu.
# Use black strokes on a transparent background — macOS recolors them for light/dark mode.
#
# Requires rsvg-convert:  brew install librsvg
# Usage:                  ./scripts/build-icons.sh

set -euo pipefail
cd "$(dirname "$0")/.."
PLUGIN="lifx.30s.sh"

command -v rsvg-convert >/dev/null || { echo "rsvg-convert not found — run: brew install librsvg"; exit 1; }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
block="$tmp/block.txt"

{
  echo "# >>> generated icons (scripts/build-icons.sh) — do not edit by hand"
  echo "# shellcheck disable=SC2034  # read indirectly by ic()"
  echo "{"
} > "$block"
for svg in icons/*.svg; do
  name=$(basename "$svg" .svg | tr '-' '_')
  png="$tmp/$name.png"
  rsvg-convert -w 32 -h 32 "$svg" -o "$png"
  if command -v sips >/dev/null; then
    sips -s dpiWidth 144 -s dpiHeight 144 "$png" >/dev/null       # macOS
  else
    python3 -c "from PIL import Image; Image.open('$png').save('$png', dpi=(144, 144))"
  fi
  echo "I_$name=\"$(base64 < "$png" | tr -d '\n')\"" >> "$block"
done
printf '%s\n' "}" "# <<< generated icons" >> "$block"

awk -v bf="$block" '
  /^# >>> generated icons/ { while ((getline line < bf) > 0) print line; skip = 1; next }
  /^# <<< generated icons/ { skip = 0; next }
  !skip
' "$PLUGIN" > "$tmp/plugin"

cat "$tmp/plugin" > "$PLUGIN"   # keeps the file's permissions
echo "Updated $(grep -c '^I_' "$PLUGIN") icons in $PLUGIN"
