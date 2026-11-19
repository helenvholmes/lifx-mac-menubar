# lifx-mac-menubar

Control your LIFX lights from the Mac menu bar: whole rooms or single lights, brightness, and color, without opening an app.

lifx-mac-menubar is a [SwiftBar](https://swiftbar.app) plugin made by [Helen V. Holmes](https://helenvholmes.com). It's free and open source under the MIT License.

<!-- TODO: add a screenshot of the open menu, e.g. docs/menu.png -->

> **Unofficial project.** lifx-mac-menubar is not affiliated with, endorsed by, or supported by LIFX. "LIFX" is a trademark of its owner and is used here only to describe what the plugin works with.

## What it does

- **Rooms first.** Lights are grouped by room, and each room has its own icon (bed, sofa, cooking pot…). You can toggle, dim, or recolor a whole room at once, or open it to control lights one by one.
- **Menus that match your lights.** Color bulbs get colors and whites. Tunable white bulbs only show the warmth settings they support. Fixed-white bulbs don't show a color menu at all.
- **Icons for each type of light.** Strips, candles, tiles, and lamps each get their own icon, detected from LIFX's product info or from the light's name.
- **All on and All off** at the top of the menu.
- **Feedback when something fails.** If a bulb doesn't respond or LIFX rejects a command, you get a notification saying which one.
- **Native look.** It uses Lucide line icons that adapt to light and dark mode.

## Requirements

- macOS with [SwiftBar](https://swiftbar.app)
- [`jq`](https://jqlang.org). Newer macOS versions include it. Otherwise run `brew install jq`.
- A LIFX account with lights set up in the LIFX app

The plugin uses the LIFX Cloud API, so your Mac needs an internet connection. It doesn't have to be on the same network as your lights.

## Install

1. **Install SwiftBar** and choose a plugins folder when it asks, e.g. `~/SwiftBar`:
   ```bash
   brew install --cask swiftbar
   ```
2. **Add the plugin to your plugins folder.** Either download [`lifx.30s.sh`](lifx.30s.sh) into it, or clone this repo and symlink the plugin so `git pull` keeps it up to date:
   ```bash
   git clone https://github.com/helenvholmes/lifx-mac-menubar.git
   ln -s "$PWD/lifx-mac-menubar/lifx.30s.sh" ~/SwiftBar/lifx.30s.sh
   chmod +x lifx-mac-menubar/lifx.30s.sh
   ```
   Link only the plugin file. Don't make the repo itself your plugins folder, because SwiftBar would try to run every file in it.
3. **Connect your LIFX account.** Click the lightbulb in your menu bar and choose **Set LIFX token…**. Create a token at [cloud.lifx.com](https://cloud.lifx.com/settings) under Settings → Personal access tokens, paste it in, and click **Save**. The plugin checks the token and stores it in your macOS Keychain.

That's it. Your rooms appear in the menu within a few seconds.

To change your token later, open the menu, **hold Option (⌥)**, and choose **Change LIFX token…**.

## Customize

Everything is in `lifx.30s.sh` and can be edited in any text editor.

**Refresh interval.** The menu updates every 30 seconds and after every click. To change the interval, rename the file: `lifx.1m.sh` updates every minute, `lifx.10s.sh` every 10 seconds.

**Icons for specific lights.** Add lines to the `ICON_OVERRIDES` list using the exact light name from the LIFX app:
```bash
ICON_OVERRIDES="
LUNA Kitchen=lamp
Bookshelf=strip
"
```

**Color and white presets.** Edit the `WHITES` list (name and Kelvin) and the `COLORS` list. Colors can be any [LIFX color name](https://api.developer.lifx.com/docs/colors).

**Room icons.** `room_icon()` chooses an icon from the room's name: bed for bedrooms, cooking pot for kitchens, sofa for living rooms, lamp for offices, and house for everything else. Add your own patterns there.

### Available icons

| Name in the script | Lucide icon | Used for |
|---|---|---|
| `lightbulb`, `lightbulb_off` | lightbulb, lightbulb-off | Menu bar, regular bulbs, All on/off |
| `lamp` | lamp | Table lamps, LIFX Luna, offices |
| `lamp_desk` | lamp-desk | Lights named desk, task, or reading |
| `lamp_floor` | lamp-floor | Lights named floor |
| `lamp_ceiling` | lamp-ceiling | Ceiling, pendant, and downlights |
| `strip` | rectangle-ellipsis | Lightstrips, LIFX Z, Beam, Neon |
| `flame` | flame | Candle bulbs |
| `grid` | grid-2x2 | Tiles and other matrix lights |
| `bed`, `sofa`, `cooking_pot`, `house` | bed, sofa, cooking-pot, house | Rooms |
| `power`, `sun`, `palette`, `refresh_cw`, `wifi_off`, `key` | same names | Menu controls and states |

### Changing or adding icons

The icon images are embedded in the script so the plugin stays a single file. Their sources are SVGs in [`icons/`](icons). To change one:

1. Replace or add an SVG in `icons/`. Grab any icon from [lucide.dev](https://lucide.dev), and use black strokes (`stroke="#000"`) on a transparent background.
2. Run the build script. It needs `rsvg-convert` (`brew install librsvg`).
   ```bash
   ./scripts/build-icons.sh
   ```
3. Use the new icon in the script as `$(ic your_icon_name)`. Dashes in file names become underscores.

## Privacy

- Your LIFX token is stored in the macOS Keychain (service name `lifx-token`), not in the script.
- The plugin only talks to `api.lifx.com`.
- Commands you send from the menu are logged to `~/Library/Logs/lifx-swiftbar.log` to help with troubleshooting, with your token redacted. You can delete this file anytime.

## Troubleshooting

- **No lightbulb in the menu bar.** Check that SwiftBar is running and its plugins folder contains `lifx.30s.sh`, and that the file is executable (`chmod +x`). On MacBooks with a notch, a crowded menu bar can hide icons behind the notch, so quit an app or two to make room.
- **A light shows as offline.** It has lost power or Wi-Fi, often because a wall switch was turned off. LIFX can't control a bulb with no power.
- **A command didn't work.** Check the notification or `~/Library/Logs/lifx-swiftbar.log` to see what LIFX said.
- **SwiftBar's own settings are gone from the menu.** This plugin hides them to keep the menu clean. Open the SwiftBar app from Spotlight to reach them, or delete the `swiftbar.hideSwiftBar` line at the top of the script.

## Credits and license

Made by [Helen V. Holmes](https://helenvholmes.com) · [GitHub](https://github.com/helenvholmes)

- Code: [MIT License](LICENSE) © 2026 Helen V. Holmes
- Icons: [Lucide](https://lucide.dev), [ISC License](LICENSE-LUCIDE), with portions derived from Feather under the MIT License
- Runs on [SwiftBar](https://swiftbar.app)
