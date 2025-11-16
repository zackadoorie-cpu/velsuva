local mod = get_mod("mission_board_unlock")

-- If the mod API is unavailable, bail out quietly so the loader doesn't throw
-- a nil-call error while scanning mods.
if not mod then
    print("[mission_board_unlock] get_mod returned nil in mod.lua; aborting entrypoint load")
    return
end

local function log_info(message)
    if mod.info then
        mod:info(message)
    else
        print("[mission_board_unlock] " .. message)
    end
end

-- Helper to load files defensively. It prefers DMF's io_dofile, but will fall
-- back to vanilla dofile if necessary and logs any failure instead of bubbling
-- a nil-call error up to the mod manager.
local function safe_dofile(path)
    local loader = mod.io_dofile or dofile
    local ok, result = pcall(function()
        if loader == mod.io_dofile then
            return mod:io_dofile(path)
        end

        return loader(path .. ".lua")
    end)

    if not ok then
        log_info(string.format("failed to load %s: %s", path, tostring(result)))
        return nil
    end

    return result
end

-- Load localization strings early so settings and UI labels resolve even if the
-- implementation hooks run slightly later.
local localization = safe_dofile("scripts/mods/mission_board_unlock/localization/localization")
if localization and mod.add_localized_strings then
    mod:add_localized_strings(localization)
elseif localization then
    log_info("Mission Board Unlock: localization loaded (no add_localized_strings helper present)")
end

-- Load the main implementation from the same directory
safe_dofile("scripts/mods/mission_board_unlock/mission_board_unlock")

-- Surface a clear log message when the entrypoint loads so players can confirm the
-- mod was picked up by the loader before the mission board view initializes.
log_info("Mission Board Unlock entrypoint loaded (mod.lua)")
