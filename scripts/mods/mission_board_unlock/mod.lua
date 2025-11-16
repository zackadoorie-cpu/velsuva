local mod = get_mod("mission_board_unlock")

-- Load localization strings early so settings and UI labels resolve even if the
-- implementation hooks run slightly later.
local localization = require("scripts/mods/mission_board_unlock/localization/localization")
if localization then
    mod:add_localized_strings(localization)
end

-- Load the main implementation from the same directory
mod:io_dofile("scripts/mods/mission_board_unlock/mission_board_unlock.lua")

-- Surface a clear log message when the entrypoint loads so players can confirm the
-- mod was picked up by the loader before the mission board view initializes.
mod:info("Mission Board Unlock entrypoint loaded (mod.lua)")
