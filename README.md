# Mission Board Unlock (Darktide Mod)

A Darktide client-side mod that removes the mission board refresh cooldown, adds a manual **Refresh Board** button, and exposes dropdown selectors for choosing a map and difficulty. Designed for modded realms where UI and client-side gating can be bypassed using the official Mod Framework.

## Features
- **No cooldown:** Disables the 60-minute refresh lock on the mission board timer UI and client gate.
- **Manual refresh:** Adds a "Refresh Board" button to immediately request new missions. The board also auto-refreshes when you open it.
- **Map & difficulty selectors:** Dropdowns let you filter or force rerolls until the board matches your choices.

## Installation
Install directly from source (no binary downloads are included):
1. Ensure you are running the Darktide Mod Framework in a modded realm.
2. Copy the `scripts/mods/mission_board_unlock` folder into your mod directory (e.g., `<Darktide>/mods` depending on your loader).
3. Enable the mod in the Mod Framework launcher or via your mod loader config.

## Usage
- Open the mission board. The timer will stay unlocked and the **Refresh Board** button will be available immediately.
- Use the map and difficulty dropdowns to pick a target combination.
- Click **Refresh Board** to re-request missions (it also auto-refreshes on open). If the backend does not allow parameterized requests, the mod will reroll once until the selections appear.

## Notes
- This mod focuses on client-side UI gating. If the backend enforces rotation intervals, you may see repeated missions until the server rotates or accepts another refresh request.
- Keep this mod within modded realms to avoid conflicts with anti-cheat or matchmaking expectations.
- The repository intentionally ships **no** binary artifacts (no zip or dist outputs). Keep uploads text-only so GitHub never sees unsupported binaries.

## Development
- Main entrypoint: `scripts/mods/mission_board_unlock/mission_board_unlock.lua`
- Metadata: `scripts/mods/mission_board_unlock/mod_data.lua`
- Localization strings live in `scripts/mods/mission_board_unlock/localization/localization.lua`
  
## Binary-free policy
- The repo contains only text-based source files (Lua + Markdown). No `.zip`, `.pak`, or other compiled assets are committed.
- `.gitattributes` and `.gitignore` ensure binary formats stay out of version control so the project remains compatible with GitHub.
