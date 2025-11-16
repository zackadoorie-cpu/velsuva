# Mission Board Unlock (Darktide Mod)

A Darktide client-side mod that removes the mission board refresh cooldown, adds a manual **Refresh Board** button, and exposes selector buttons for choosing a map and difficulty. Designed for modded realms where UI and client-side gating can be bypassed using the official Mod Framework.

## Features
- **No cooldown:** Disables the 60-minute refresh lock on the mission board timer UI and client gate.
- **Manual refresh:** Adds a "Refresh Board" button to immediately request new missions. The board also auto-refreshes when you open it.
- **Map & difficulty selectors:** Buttons let you cycle choices and request rerolls until the board matches your picks.

## Installation
Install directly from source (no binary downloads are included):
1. Ensure you are running the Darktide Mod Framework in a modded realm.
2. Copy the entire `scripts/mods/mission_board_unlock` folder into your Darktide mods directory so the path is exactly `<Darktide>/mods/mission_board_unlock`.
3. Add `mission_board_unlock` to your `mod_load_order.txt` **after** `darktide-mod-framework` (example file included at repo root). The entries must exactly match the folder names inside `<Darktide>/mods/` (no spaces or comments).
4. Enable the mod in the Mod Framework launcher or via your mod loader config.

### Troubleshooting load errors
- If you see `Mod file is invalid or missing`, double-check that each mod folder listed in `mod_load_order.txt` exists under `<Darktide>/mods/` **and** contains a `mod.lua` file. This repo includes one at `scripts/mods/mission_board_unlock/mod.lua`—make sure it is present in your installed copy.
- The mod prints `Mission Board Unlock entrypoint loaded (mod.lua)` to the in-game console/log when the loader executes it. If you don't see that line, the loader did not find `mod.lua` (verify the file path and folder name).
- Match the folder names exactly in `mod_load_order.txt` (for example, the framework folder is commonly installed as `darktide-mod-framework` rather than a spaced name, and `mission_board_unlock` must match the mod folder name). Remove any comment lines or prefixes.

## Usage
- Open the mission board. The timer will stay unlocked and the **Refresh Board** button will be available immediately in the upper right of the board panel (next to other panel widgets).
- Use the map and difficulty selector buttons on the board to cycle through options.
- Click **Refresh Board** to re-request missions (it also auto-refreshes on open). If the backend does not allow parameterized requests, the mod will reroll once until the selections appear.
- When the view loads successfully, a chat log line appears: `Mission Board Unlock UI attached (refresh/map/difficulty/status).` Use this to confirm the widgets were injected.
- If the mod does not appear in-game, double-check the folder name (`mission_board_unlock`) and that `mission_board_unlock` is listed in `mod_load_order.txt`.

## Notes
- This mod focuses on client-side UI gating. If the backend enforces rotation intervals, you may see repeated missions until the server rotates or accepts another refresh request.
- Keep this mod within modded realms to avoid conflicts with anti-cheat or matchmaking expectations.
- The repository intentionally ships **no** binary artifacts (no zip or dist outputs). Keep uploads text-only so GitHub never sees unsupported binaries.
- A small status label ("Mission Board Unlock") appears under the selectors when the mod is active inside the mission board UI.

## Development
- Main entrypoint: `scripts/mods/mission_board_unlock/mission_board_unlock.lua`
- Metadata: `scripts/mods/mission_board_unlock/mod_data.lua`
- Localization strings live in `scripts/mods/mission_board_unlock/localization/localization.lua`
  
## Binary-free policy
- The repo contains only text-based source files (Lua + Markdown). No `.zip`, `.pak`, or other compiled assets are committed.
- `.gitattributes` and `.gitignore` ensure binary formats stay out of version control so the project remains compatible with GitHub.
