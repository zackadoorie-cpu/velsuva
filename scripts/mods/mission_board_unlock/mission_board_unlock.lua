local mod = get_mod("mission_board_unlock")

-- Utility: reads user config flags
local function is_enabled(setting_id)
return mod:get(setting_id) ~= false
end

-- Attempt to pull map/difficulty catalogs at load so dropdowns can be populated
local map_options = {
{ text = mod:localize("map_dropdown_label"), value = "any" },
}
local difficulty_options = {
{ text = mod:localize("difficulty_dropdown_label"), value = "any" },
}

-- Populate dropdowns when the mission board UI module is loaded
mod:hook_require("scripts/ui/views/mission_board_view/mission_board_view_definitions", function(definitions)
if not definitions or not definitions.widgets then
return definitions
end

local widgets = definitions.widgets

-- Helper to prepend new widget definitions safely
local function insert_widget(name, widget)
if not widgets[name] then
widgets[name] = widget
end
end

insert_widget("refresh_button", {
pass_template = "button_primary",
style_id = "refresh_button",
content = {
text = mod:localize("refresh_button"),
hotspot = {},
},
style = {
size = { 320, 42 },
offset = { 0, -80, 0 },
},
})

insert_widget("map_dropdown", {
pass_template = "drop_down",
value = "any",
options = map_options,
content = {
label = mod:localize("map_dropdown_label"),
},
})

insert_widget("difficulty_dropdown", {
pass_template = "drop_down",
value = "any",
options = difficulty_options,
content = {
label = mod:localize("difficulty_dropdown_label"),
},
})

return definitions
end)

-- Hook the mission board view/controller to disable timers and add callbacks
mod:hook_require("scripts/ui/views/mission_board_view/mission_board_view", function(view)
-- force cooldown off in the timer update
mod:hook_safe(view, "_update_refresh_timer", function(self)
if not is_enabled("unlock_board") then
return
end

self._cooldown_time = 0
self._refresh_cooldown = 0
self._refresh_locked = false

local button = self._widgets_by_name and self._widgets_by_name.refresh_button
if button and button.content then
button.content.disabled = false
end
end)

-- add handler for the injected refresh button
mod:hook_safe(view, "on_refresh_button_pressed", function(self)
if not is_enabled("allow_manual_refresh") then
return
end

local service = self._mission_board and self._mission_board._mission_board_service
if service and service.refresh_missions then
service:refresh_missions()
self._refresh_locked = not is_enabled("unlock_board")
end
end)

-- override mission selection/refresh pipeline to respect dropdown choices when possible
mod:hook_safe(view, "_handle_backend_mission_result", function(self, missions)
local preferred_map = self._widgets_by_name and self._widgets_by_name.map_dropdown and self._widgets_by_name.map_dropdown.value
local preferred_difficulty = self._widgets_by_name and self._widgets_by_name.difficulty_dropdown and self._widgets_by_name.difficulty_dropdown.value

local function matches_preferences(mission)
local ok_map = preferred_map == "any" or mission.map == preferred_map or mission.map_name == preferred_map
local ok_diff = preferred_difficulty == "any" or mission.difficulty == preferred_difficulty or mission.challenge == preferred_difficulty
return ok_map and ok_diff
end

if preferred_map ~= "any" or preferred_difficulty ~= "any" then
local all_match = true
for _, mission in pairs(missions or {}) do
if not matches_preferences(mission) then
all_match = false
break
end
end

-- If nothing matches, and backend refresh is allowed, reroll once
if not all_match and not is_enabled("respect_backend_lock") then
local service = self._mission_board and self._mission_board._mission_board_service
if service and service.refresh_missions then
service:refresh_missions({ preferred_map = preferred_map, preferred_difficulty = preferred_difficulty })
return
end
end
end
end)

return view
end)

-- Fallback catalog population: try to read missions when the service is loaded
mod:hook_require("scripts/managers/live_event/live_event_manager", function(manager)
mod:hook_safe(manager, "_cache_missions", function(self, missions)
if not missions then
return
end

local seen_maps = {}
local seen_difficulties = {}
for _, mission in pairs(missions) do
if mission.map and not seen_maps[mission.map] then
seen_maps[mission.map] = true
table.insert(map_options, { text = mission.map, value = mission.map })
end
if mission.difficulty and not seen_difficulties[mission.difficulty] then
seen_difficulties[mission.difficulty] = true
table.insert(difficulty_options, { text = mission.difficulty, value = mission.difficulty })
end
end
end)

return manager
end)

-- Simple debug log so users can confirm the mod loaded
mod:echo("Mission Board Unlock loaded. Cooldowns disabled: %s, manual refresh: %s", tostring(is_enabled("unlock_board")), tostring(is_enabled("allow_manual_refresh")))
