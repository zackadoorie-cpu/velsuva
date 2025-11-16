local mod = get_mod("mission_board_unlock")

-- Load the main implementation. Keeping the logic in a separate file helps avoid
-- reloading or redefining hooks when the mod loader scans for `mod.lua`.
mod:io_dofile("scripts/mods/mission_board_unlock/mission_board_unlock")

-- Surface a clear log message when the entrypoint loads so players can confirm the
-- mod was picked up by the loader before the mission board view initializes.
mod:info("Mission Board Unlock entrypoint loaded (mod.lua)")
