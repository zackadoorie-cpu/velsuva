local mod = get_mod("mission_board_unlock")

-- Startup confirmation so the loader log clearly shows when the mod entrypoint is executed
mod:info("Mission Board Unlock entrypoint loaded (mission_board_unlock.lua)")

-- Utility: reads user config flags
local function is_enabled(setting_id)
    return mod:get(setting_id) ~= false
end

-- Attempt to pull map/difficulty catalogs at load so selectors can be populated
local map_options = {
    { text = mod:localize("map_dropdown_label"), value = "any" },
}
local difficulty_options = {
    { text = mod:localize("difficulty_dropdown_label"), value = "any" },
}

-- Keep state to avoid infinite rerolls
local rerolled_for_preferences = false
local widgets_instantiated = false

-- Populate selectors when the mission board UI module is loaded
mod:hook_require("scripts/ui/views/mission_board_view/mission_board_view_definitions", function(definitions)
    if not definitions then
        return definitions
    end

    -- Some Darktide builds expose widget definitions via `widget_definitions` (map) plus a
    -- `widgets` array of names. Others use `widgets` as the definition map itself. Handle both
    -- so our controls get instantiated and added to the rendering list.
    local widget_definitions = definitions.widget_definitions or definitions.widgets or {}
    definitions.widget_definitions = widget_definitions

    -- Ensure a predictable anchor; fall back to screen if the panel is missing
    local anchor_parent = "panel_area"
    if not (definitions.scenegraph_definition and definitions.scenegraph_definition[anchor_parent]) then
        anchor_parent = "screen"
    end

    local anchor_id = "mission_board_unlock_anchor"
    definitions.scenegraph_definition = definitions.scenegraph_definition or {}
    if not definitions.scenegraph_definition[anchor_id] then
        definitions.scenegraph_definition[anchor_id] = {
            parent = anchor_parent,
            vertical_alignment = "top",
            horizontal_alignment = "right",
            size = { 320, 180 },
            position = { -20, -60, 2 },
        }
    end

    local function insert_widget(name, widget)
        if not widget_definitions[name] then
            widget_definitions[name] = widget
        end
    end

    insert_widget("refresh_button", {
        pass_template = "button_primary",
        scenegraph_id = anchor_id,
        content = {
            text = mod:localize("refresh_button"),
            hotspot = {},
        },
        style = {
            size = { 320, 42 },
            offset = { 0, 0, 1 },
        },
    })

    insert_widget("map_button", {
        pass_template = "button_secondary",
        scenegraph_id = anchor_id,
        content = {
            label = mod:localize("map_dropdown_label"),
            text = mod:localize("map_dropdown_label"),
            hotspot = {},
        },
        style = {
            size = { 320, 36 },
            offset = { 0, 52, 1 },
        },
    })

    insert_widget("difficulty_button", {
        pass_template = "button_secondary",
        scenegraph_id = anchor_id,
        content = {
            label = mod:localize("difficulty_dropdown_label"),
            text = mod:localize("difficulty_dropdown_label"),
            hotspot = {},
        },
        style = {
            size = { 320, 36 },
            offset = { 0, 96, 1 },
        },
    })

    insert_widget("unlock_status", {
        pass_template = "text_area",
        scenegraph_id = anchor_id,
        content = {
            text = mod:localize("status_label_loading"),
        },
        style = {
            text_color = { 255, 200, 255, 200 },
            font_size = 18,
            size = { 320, 60 },
            offset = { 0, 140, 1 },
        },
    })

    -- Guarantee the widgets are part of the instantiation list when `widgets` is an array of names
    if type(definitions.widgets) == "table" then
        local function ensure_widget_name(name)
            for _, entry in ipairs(definitions.widgets) do
                if entry == name or entry.name == name then
                    return
                end
            end

            table.insert(definitions.widgets, name)
        end

        ensure_widget_name("refresh_button")
        ensure_widget_name("map_button")
        ensure_widget_name("difficulty_button")
        ensure_widget_name("unlock_status")
    end

    return definitions
end)

local function ensure_widget_instances(self)
    if not (self._definitions and self._ui_scenegraph and self._widgets_by_name and self._widgets) then
        return
    end

    local widget_definitions = self._definitions.widget_definitions or self._definitions.widgets or {}
    local widget_names = {
        "refresh_button",
        "map_button",
        "difficulty_button",
        "unlock_status",
    }

    local injected = false

    for _, name in ipairs(widget_names) do
        local definition = widget_definitions[name]
        if definition and not self._widgets_by_name[name] then
            local widget = self:_create_widget(name, definition)
            if widget then
                self._widgets_by_name[name] = widget
                self._widgets[#self._widgets + 1] = widget
                injected = true
            end
        end
    end

    if injected and not widgets_instantiated then
        widgets_instantiated = true
        mod:echo("Mission Board Unlock UI widgets injected into mission board view.")
    end
end

local function unlock_refresh_state(self)
    if not is_enabled("unlock_board") then
        return
    end

    self._cooldown_time = 0
    self._refresh_cooldown = 0
    self._refresh_locked = false

    local service = self._mission_board and self._mission_board._mission_board_service
    if service then
        service._refresh_cooldown = 0
        service._refresh_locked = false
        service._next_refresh_time = 0
    end

    if self._widgets_by_name then
        local button = self._widgets_by_name.refresh_button
        if button and button.content then
            button.content.disabled = false
        end

        local status = self._widgets_by_name.unlock_status
        if status and status.content then
            status.content.text = mod:localize("status_label_unlocked")
        end
    end
end

local function refresh_board(self, preferred_map, preferred_difficulty)
    local service = self._mission_board and self._mission_board._mission_board_service
    if service and service.refresh_missions then
        service:refresh_missions({
            preferred_map = preferred_map,
            preferred_difficulty = preferred_difficulty,
        })
        mod:echo("Mission board refreshed (cooldown bypassed).")
    else
        mod:echo("Mission board service unavailable; cannot refresh.")
    end
end

local function cycle_option(widget, options)
    if not widget or not widget.content or not options then
        return nil
    end

    local current_index = widget.content._current_index or 1
    local next_index = current_index + 1
    if next_index > #options then
        next_index = 1
    end

    widget.content._current_index = next_index
    widget.content.text = string.format("%s: %s", widget.content.label, options[next_index].text)

    return options[next_index].value
end

local function ensure_selector_text(widget, options)
    if widget and widget.content and options and not widget.content._current_index then
        widget.content._current_index = 1
        widget.content.text = string.format("%s: %s", widget.content.label, options[1].text)
    end
end

local function read_selector_value(widget, options)
    if widget and widget.content and widget.content._current_index then
        return options[widget.content._current_index].value
    end

    return "any"
end

-- Hook the mission board view/controller to disable timers and add callbacks
mod:hook_require("scripts/ui/views/mission_board_view/mission_board_view", function(view)
    -- force cooldown off as soon as the view opens
    mod:hook_safe(view, "on_enter", function(self)
        ensure_widget_instances(self)
        unlock_refresh_state(self)

        ensure_selector_text(self._widgets_by_name and self._widgets_by_name.map_button, map_options)
        ensure_selector_text(self._widgets_by_name and self._widgets_by_name.difficulty_button, difficulty_options)

        if is_enabled("allow_manual_refresh") then
            refresh_board(self)
        end

        if self._widgets_by_name then
            mod:echo("Mission Board Unlock UI attached (refresh/map/difficulty/status).")
        else
            mod:echo("Mission Board Unlock: widget table missing; view may be incompatible.")
        end
    end)

    -- keep cooldown disabled while the view runs
    mod:hook_safe(view, "update", function(self, ...)
        ensure_widget_instances(self)
        unlock_refresh_state(self)

        local map_widget = self._widgets_by_name and self._widgets_by_name.map_button
        local diff_widget = self._widgets_by_name and self._widgets_by_name.difficulty_button
        ensure_selector_text(map_widget, map_options)
        ensure_selector_text(diff_widget, difficulty_options)

        if map_widget and map_widget.content and map_widget.content.hotspot and map_widget.content.hotspot.on_pressed then
            cycle_option(map_widget, map_options)
        end

        if diff_widget and diff_widget.content and diff_widget.content.hotspot and diff_widget.content.hotspot.on_pressed then
            cycle_option(diff_widget, difficulty_options)
        end

        local button = self._widgets_by_name and self._widgets_by_name.refresh_button
        if button and button.content and button.content.hotspot and button.content.hotspot.on_pressed then
            local preferred_map = read_selector_value(map_widget, map_options)
            local preferred_difficulty = read_selector_value(diff_widget, difficulty_options)

            refresh_board(self, preferred_map, preferred_difficulty)
            self._refresh_locked = not is_enabled("unlock_board")
        end
    end)

    -- override mission selection/refresh pipeline to respect dropdown choices when possible
    mod:hook_safe(view, "_handle_backend_mission_result", function(self, missions)
        local preferred_map = read_selector_value(self._widgets_by_name and self._widgets_by_name.map_button, map_options)
        local preferred_difficulty = read_selector_value(self._widgets_by_name and self._widgets_by_name.difficulty_button, difficulty_options)

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
            if not all_match and not is_enabled("respect_backend_lock") and not rerolled_for_preferences then
                rerolled_for_preferences = true
                refresh_board(self, preferred_map, preferred_difficulty)
                return
            end
        end

        rerolled_for_preferences = false
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
mod:echo(
    "Mission Board Unlock loaded. Cooldowns disabled: %s, manual refresh: %s",
    tostring(is_enabled("unlock_board")),
    tostring(is_enabled("allow_manual_refresh"))
)
