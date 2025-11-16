local mod = get_mod("mission_board_unlock")

-- Load the main implementation. Keeping the logic in a separate file helps avoid
-- reloading or redefining hooks when the mod loader scans for `mod.lua`.
mod:io_dofile("mission_board_unlock/scripts/mods/mission_board_unlock/mission_board_unlock")
