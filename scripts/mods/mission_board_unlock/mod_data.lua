local mod = get_mod("mission_board_unlock")

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    author = "Community",
    version = "1.0.0",
    hot_reload = true,
    options = {
        widgets = {
            {
                setting_id = "unlock_board",
                type = "checkbox",
                default_value = true,
            },
            {
                setting_id = "allow_manual_refresh",
                type = "checkbox",
                default_value = true,
            },
            {
                setting_id = "respect_backend_lock",
                type = "checkbox",
                default_value = false,
            },
        }
    }
}
