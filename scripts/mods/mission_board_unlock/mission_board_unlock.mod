return {
    name = "mission_board_unlock",
    description = "Removes the mission board cooldown, adds refresh/map/difficulty controls, and keeps the board unlocked.",
    author = "Community",
    version = "1.0.0",
    is_mutator = false,
    is_togglable = true,
    is_enabled_by_default = true,
    dependencies = {
        "dmf",
    },
    script_path = "scripts/mods/mission_board_unlock/mod.lua",
    options_path = "scripts/mods/mission_board_unlock/mod_data",
}
