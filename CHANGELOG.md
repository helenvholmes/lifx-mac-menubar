# Changelog

## v1.0.0 — 2026-11-18

First public release.

- Menu bar control for LIFX lights through the LIFX Cloud API
- Lights grouped by room, with toggle, brightness, and color for each room and light
- Menus adapt to each light: color bulbs get colors and whites, tunable bulbs get only the white temperatures they support, and fixed-white bulbs get no color menu
- Lucide icons throughout, with per-room and per-light-type icons (strips, candles, tiles, lamps)
- Per-light icon overrides
- In-menu token setup ("Set LIFX token…"), stored in the macOS Keychain
- Notifications when LIFX rejects a command or a bulb doesn't respond, plus a local log
- Icon sources in `icons/`, with `scripts/build-icons.sh` to regenerate them
