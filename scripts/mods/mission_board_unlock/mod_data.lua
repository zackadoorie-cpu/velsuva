local mod = get_mod("mission_board_unlock")

local function safe_localize(key, fallback)
    if mod and mod.localize then
        local ok, value = pcall(mod.localize, mod, key)
        if ok and value then
            return value
        end
    end

    return fallback
end

return {
    name = safe_localize("mod_name", "Mission Board Unlock"),
    description = safe_localize(
        "mod_description",
        "Removes the mission board cooldown, adds a manual refresh button, and exposes map/difficulty dropdowns."
    ),
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
