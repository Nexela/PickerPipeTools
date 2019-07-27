-------------------------------------------------------------------------------
--[[Pipe Highlighter]] --
-------------------------------------------------------------------------------
-- Concept designed and code written by TheStaplergun (staplergun on mod portal)
-- STDLib and code reviews provided by Nexela

local Player = require('__stdlib__/stdlib/event/player')
local Event = require('__stdlib__/stdlib/event/event')
local Position = require('__stdlib__/stdlib/area/position')
local Direction = require('__stdlib__/stdlib/area/direction')
local utils = require('scripts/utils')
local t = require('utils/tables')
local d = require('draw')
local bor = bit32.bor
local lshift = bit32.lshift
local pipe_connections = {}
local MAX_PIPES_PER_TICK = 250

local function load_pipe_connections()
    if remote.interfaces['underground-pipe-pack'] then
        pipe_connections = remote.call('underground-pipe-pack', 'get_pipe_table')
    end
end
Event.register({Event.core_events.init, Event.core_events.load}, load_pipe_connections)

local function get_directions_pipe(entity_data)
    local table_entry = 0
    local entity_neighbours = current_entity[2]
    for _, neighbour in pairs(entity_data[2]) do
        table_entry = bor(table_entry, lshift(1, utils.get_direction(entity_data[1], current_neighbour[1])))
    end
    return table_entry
end

local function check_if_orphan(entity_data)
    if #entity_data[2] < 2 then
        return entity_data[3] ~= 'pump' and not t.draw_dashes_names[entity_data[4]] or entity_data[1].pump_rail_target
    end
    return false
end

local function map_to_junction(unit_number, entity_data, player_index)
    local markers_to_update = {pdata.current_marker_table[unit_number]}
    local function step(s_unit_number, s_entity_data)
        for n_unit_number, n_data in pairs(entity_data[2]) do
            markers_to_update[#markers_to_update + 1] = pdata.current_marker_table[s_unit_number]
        end
    end
    step(unit_number, entity_data)
    d.update_markers(markers_to_update, player_index)
end

local function highlight_pipeline(starter_entity, player_index, current_color)
    local player, pdata = Player.get(player_index)
    local read_entity_data = {}
    local read_neighbour_data = {}
    local all_entities_marked = pdata.current_pipenet_table and pdata.current_pipenet_table or {}
    local all_markers = pdata.current_marker_table and pdata.current_marker_table or {}
    local orphans = {}
    local pipes_read = 0
    local markers_made = next(all_markers) and #all_markers or 0

    pdata.current_marker_table = all_markers
    pdata.current_beltnet_table = all_entities_marked

    pdata.scheduled_markers = pdata.scheduled_markers or {}

    local working_table = 1
    if pdata.scheduled_markers[1] and next(pdata.scheduled_markers[1]) then
        working_table = 2
    end
    pdata.scheduled_markers[working_table] = pdata.scheduled_markers[working_table] or {}

    local function read_pipeline(entity, entity_unit_number, entity_position, entity_type, entity_name)
        local entity_neighbours = entity.neighbours[1]
        read_entity_data[entity_unit_number] = {
            entity_position,
            entity_neighbours,
            entity_type,
            entity_name,
            entity,
            mark_color = current_color
        }
        local current_entity = read_entity_data[entity_unit_number]
        pipes_read = pipes_read + 1
        local is_orphan = check_if_orphan(current_entity)
        if is_orphan then
            orphans[#orphans + 1] = current_entity
        end
        if current_color == d.green then
            d.update_markers(all_markers, d.yellow)
        end
        current_color = d.yellow
        for neighbour_index_number, neighbour in pairs(entity_neighbours) do
            local n_unit_number = neighbour.unit_number
            if read_entity_data[n_unit_number] then
                entity_neighbours[neighbour_index_number] = read_entity_data[n_unit_number]
            elseif all_entities_marked[n_unit_number] then
                entity_neighbours[neighbour_index_number] = {
                    false,
                    false,
                    false,
                    false,
                    neighbour
                }
            else
                local neighbour_type = neighbour.type
                if t.allowed_types[neighbour_type] and not t.not_allowed_names[neighbour_name] then
                    local neighbour_name = neighbour.name
                    local neighbour_position = neighbour.position
                    local neighbour_unit_number = neighbour.unit_number
                    entity_neighbours[neighbour_index_number] = neighbour_unit_number
                    if pipes_read < MAX_PIPES_PER_TICK then
                        --? Step to next pipe
                        return read_pipeline(neighbour, neighbour_unit_number, neighbour_position, neighbour_type, neighbour_name)
                    else
                        global.marking = true
                        global.marking_players[player_index] = true
                        local wt = pdata.scheduled_markers[working_table]
                        wt[#wt + 1] = {
                            neighbour,
                            current_color
                        }
                    end
                else
                    all_markers[#all_markers + 1] = d.mark_neighbour(current_entity, neighbour)
                end
            end
        end
    end
    --? Entry point to read pipeline
    local starter_unit_number = starter_entity.unit_number
    local starter_entity_name = starter_entity.name
    local starter_entity_type = starter_entity.type
    local starter_entity_position = starter_entity.position
    read_pipeline(starter_entity, starter_unit_number, starter_entity_position, starter_entity_type, starter_entity_name)


    if next(orphans) then
        for _, entity_data in orphans do
            d.draw_dot(entity_data, d.red, player_index)
            map_to_junction(entity_data, player_index)
        end
    end
end
