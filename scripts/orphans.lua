--[[
    "name": "Orphan Finder",
    "title": "Orphan Finder",
    "author": "GotLag",
    "description": "Adds a hotkey to highlight unconnected undergound pipes/belts near the player."
    "homepage": "https://mods.factorio.com/mods/GotLag/Orphan%20Finder"
--]]

local Event = require('__stdlib__/stdlib/event/event')
local Player = require('__stdlib__/stdlib/event/player')
local Position = require('__stdlib__/stdlib/area/position')
local Time = require('__stdlib__/stdlib/utils/defines/time')

-- Trigger orphan finder with these
local check_for = {
    ['underground-belt'] = 'underground-belt',
    ['transport-belt'] = 'underground-belt',
    ['pipe-to-ground'] = 'pipe-to-ground',
    ['pipe'] = 'pipe-to-ground'
}

-- Build orphans for these.
local undergrounds = {
    ['underground-belt'] = 'underground-belt',
    ['pipe-to-ground'] = 'pipe-to-ground'
}

local function _find_mark(entity)
    return entity.surface.find_entity('picker-highlight-box', entity.position)
end

local function _destroy_mark(entity)
    local mark = _find_mark(entity)
    if mark then
        mark.destroy()
    end
end

-- Find orphans when hovering over types with undergrounds, or changing cursor stack to types with underlines.
local function find_orphans(event)
    local player, pdata = Player.get(event.player_index)
    local cursor_type = player.cursor_stack and player.cursor_stack.valid_for_read and player.cursor_stack.prototype.place_result and
        check_for[player.cursor_stack.prototype.place_result.type]
    if (player.selected and check_for[player.selected.type]) or cursor_type then
        local e_type = player.selected and check_for[player.selected.type] or cursor_type
        if (event.tick > (pdata['next_check_' .. e_type] or 0)) and player.mod_settings['picker-find-orphans'].value then
            local ent = player.selected or player
            local filter = { area = Position(ent.position):expand_to_area(64), type = e_type, force = player.force }
            for _, entity in pairs(ent.surface.find_entities_filtered(filter)) do
                local not_con = not entity.neighbours or (entity.neighbours and not entity.neighbours.type and #entity.neighbours[1] < 2)

                if not_con and not _find_mark(entity) then
                    entity.surface.create_entity {
                        name = 'picker-highlight-box',
                        target = entity,
                        render_player_index = 1,
                        position = entity.position,
                        box_type = 'not-allowed',
                        force = player.force,
                        time_to_live = 60 * 10,
                        blink_interval = 30
                    }
                end
            end
            pdata['next_check_' .. e_type] = event.tick + (Time.second * 10)
        end
    end
end
Event.register({ defines.events.on_selected_entity_changed, defines.events.on_player_cursor_stack_changed }, find_orphans)

-- When building an underground object remove orphan marks that are no longer needed.
local function orphan_builder(event)
    if undergrounds[event.created_entity.type] and event.created_entity.neighbours then
        local _, pdata = Player.get(event.player_index)
        local entities = event.created_entity.neighbours

        if not entities.type then
            for _, inner in pairs(entities) do
                for _, ent in pairs(inner) do
                    _destroy_mark(ent)
                end
            end
        else
            _destroy_mark(entities)
        end
        pdata._next_check = event.tick + (Time.second * 2)
    end
end
Event.register(defines.events.on_built_entity, orphan_builder)
