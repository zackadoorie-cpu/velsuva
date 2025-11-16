local mod = get_mod("mission_board_unlock")

-- If the mod API is unavailable, bail out quietly to avoid nil-call crashes. Do not
-- use Log.* helpers here because they may also be missing when get_mod fails.
if not mod then
    print("[mission_board_unlock] get_mod returned nil in mod.lua; aborting entrypoint load")
    return
end

-- Gracefully load other Lua files even if the DMF helper `io_dofile` is missing
-- in this environment. If it's absent, fall back to plain dofile so the loader
-- doesn't crash with "attempt to call a nil value".
local function safe_dofile(path)
    if mod.io_dofile then
        return mod:io_dofile(path)
    end

    -- DMF normally resolves mod-relative paths automatically; mimic that
    -- behaviour by appending ".lua" when using the vanilla loader.
    local ok, result = pcall(dofile, path .. ".lua")
    if not ok then
        print(string.format("[mission_board_unlock] failed to load %s: %s", path, tostring(result)))
    end

    return result
end

-- Load localization strings early so settings and UI labels resolve even if the
-- implementation hooks run slightly later. The add_localized_strings helper is
-- not guaranteed on every DMF build, so guard it to avoid nil-call failures.
local localization = require("scripts/mods/mission_board_unlock/localization/localization")
if localization and mod.add_localized_strings then
    mod:add_localized_strings(localization)
elseif localization then
    mod:info("Mission Board Unlock: localization loaded (no add_localized_strings helper present)")
end

-- Load the main implementation from the same directory
safe_dofile("scripts/mods/mission_board_unlock/mission_board_unlock")

-- Surface a clear log message when the entrypoint loads so players can confirm the
-- mod was picked up by the loader before the mission board view initializes.
if mod.info then
    mod:info("Mission Board Unlock entrypoint loaded (mod.lua)")
else
    print("[mission_board_unlock] entrypoint loaded (mod.lua)")
end
