# Mission Board Unlock (Darktide Mod)

Removes the mission board cooldown, adds a manual **Refresh Board** button, and exposes map/difficulty selectors so you can reroll missions at will in modded realms.

## Installation
1. Create the folder structure exactly as shown (all files are required by the loader):
   - `mission_board_unlock/`
   - `mission_board_unlock/localization/`
   - Place `mission_board_unlock.mod`, `mod.json`, `mod_data.lua`, and `mission_board_unlock.lua` directly inside `mission_board_unlock/`.
   - Place `localization.lua` inside `mission_board_unlock/localization/`.
2. Copy the entire `mission_board_unlock/` folder to `<Darktide>/mods/` so the path is `<Darktide>/mods/mission_board_unlock/`.
3. Ensure `mod_load_order.txt` contains **only** the folder names (one per line) that match your installed mod folders:
   - `dmf` (the Darktide Mod Framework folder name)
   - `mission_board_unlock`
4. Confirm `mission_board_unlock.mod` exists in the installed folder; this manifest is what DMF loads. `mod.json` mirrors the same metadata, declares `dmf` as a dependency, and both point `script_path` to `scripts/mods/mission_board_unlock/mod.lua` (which loads `mod.lua`, then `mission_board_unlock.lua`).
5. Start the game in a modded realm. You should see `Mission Board Unlock entrypoint loaded (mission_board_unlock.lua)` in the console when the loader picks up the mod.

## Usage
- Open the mission board; the cooldown will be disabled automatically.
- Use the **Refresh Board**, **Preferred Map**, and **Preferred Difficulty** buttons that appear on the board panel to cycle options and reroll missions.
- The status label updates when the board is unlocked.

## Files
- `mission_board_unlock.mod`: DMF manifest the loader consumes to locate scripts and options.
- `mod.json`: Manifest metadata (including `script_path`).
- `mod.lua`: Helper entrypoint that loads localization and then `mission_board_unlock.lua`.
- `mod_data.lua`: Mod options and descriptions.
- `mission_board_unlock.lua`: Core logic for disabling the cooldown, injecting UI controls, and handling refreshes (and logs the entrypoint load message).
- `localization/localization.lua`: Localization strings for UI labels and settings.

All assets are source-only (Lua/JSON/text) so the project remains GitHub-friendly without bundled binaries.
