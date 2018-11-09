-------------------------------------------------------------------------------
--[ Pipe Highlighter ] -- Concept designed and code written by TheStaplergun (staplergun on mod portal) revised by Nexela
-------------------------------------------------------------------------------

local Player = require('lib/player')
local Event = require('lib/event')

local pipe_connections = {}
local function load_pipe_connections()
    if remote.interfaces['underground-pipe-pack'] then
        pipe_connections = remote.call('underground-pipe-pack', 'get_pipe_table')
    end
end
Event.register({Event.core_events.init, Event.core_events.load}, load_pipe_connections)

local function show_underground_sprites(event)
    local player = game.players[event.player_index]
    local current_surface_create = player.surface
    local filter = {
        area = {{player.position.x - 80, player.position.y - 50}, {player.position.x + 80, player.position.y + 50}},
        type = {'pipe-to-ground', 'pump'},
        force = player.force
    }
    for _, entity in pairs(player.surface.find_entities_filtered(filter)) do
        if entity.type == 'pipe-to-ground' or (entity.type == 'pump' and entity.name == 'underground-mini-pump') then
            local maxNeighbors = pipe_connections[entity.name] or 2
            for _, entities in pairs(entity.neighbours) do
                local neighbour_count = #entities
                for _, neighbour in pairs(entities) do
                    if neighbour.type == 'pipe-to-ground' or (neighbour.type == 'pump' and neighbour.name == 'underground-mini-pump') then
                        if (entity.position.x - neighbour.position.x) < -1.5 then
                            local distancex = neighbour.position.x - entity.position.x
                            for i = 1, distancex - 1, 1 do
                                player.surface{
                                    name = 'picker-underground-pipe-marker-horizontal',
                                    position = {entity.position.x + i, entity.position.y}
                                }
                            end
                        end
                        if (entity.position.y - neighbour.position.y) < -1.5 then
                            local distancey = neighbour.position.y - entity.position.y
                            for i = 1, distancey - 1, 1 do
                                player.surface{
                                    name = 'picker-underground-pipe-marker-vertical',
                                    position = {entity.position.x, entity.position.y + i}
                                }
                            end
                        end
                    end
                end
                if (maxNeighbors == neighbour_count) then
                    current_surface_create{
                        name = 'picker-pipe-marker-box-good',
                        position = entity.position
                    }
                elseif (neighbour_count < maxNeighbors) then
                    current_surface_create{
                        name = 'picker-pipe-marker-box-bad',
                        position = entity.position
                    }
                end
            end
        end
    end
end
Event.register('picker-show-underground-paths', show_underground_sprites)

local function get_ew(delta_x)
    return delta_x > 0 and defines.direction.west or defines.direction.east
end

local function get_ns(delta_y)
    return delta_y > 0 and defines.direction.north or defines.direction.south
end

local function get_direction(entity_position, neighbour_position)
    --[[if not entity.valid or not neighbour.valid then
        return
    end]]--
    local delta_x = entity_position.x - neighbour_position.x
    local delta_y = entity_position.y - neighbour_position.y
    if delta_x ~= 0 and delta_y == 0 then
        return get_ew(delta_x)
    elseif delta_x == 0 and delta_y ~= 0 then
        return get_ns(delta_y)
    elseif delta_x ~= 0 and delta_y ~= 0 then
        if math.abs(delta_x) > math.abs(delta_y) then
            return get_ew(delta_x)
        elseif math.abs(delta_x) < math.abs(delta_y) then
            return get_ns(delta_y)
        end
    end
end

local allowed_types =
{
    ["pipe"] = true,
    ["pipe-to-ground"] = true,
    ["pump"] = true
}
local not_allowed_names =
{
    ["factory-fluid-dummy-connector"] = true,
    ["factory-fluid-dummy-connector-south"] = true,
}
local pipe_highlight_markers = {
    dash = {
        ['normal'] = {
            [defines.direction.north] = 'picker-pipe-marker-ns',
            [defines.direction.east] = 'picker-pipe-marker-ew',
            [defines.direction.west] = 'picker-pipe-marker-ew',
            [defines.direction.south] = 'picker-pipe-marker-ns',
        },
        ['good'] = {
            [defines.direction.north] = 'picker-pipe-marker-good-ns',
            [defines.direction.east] = 'picker-pipe-marker-good-ew',
            [defines.direction.west] = 'picker-pipe-marker-good-ew',
            [defines.direction.south] = 'picker-pipe-marker-good-ns',
        },
        ['bad'] = {
            [defines.direction.north] = 'picker-pipe-marker-bad-ns',
            [defines.direction.east] = 'picker-pipe-marker-bad-ew',
            [defines.direction.west] = 'picker-pipe-marker-bad-ew',
            [defines.direction.south] = 'picker-pipe-marker-bad-ns',
        }
    },
    dot = {
        ['normal'] = 'picker-pipe-dot',
        ['good'] = 'picker-pipe-dot-good',
        ['bad'] = 'picker-pipe-dot-bad'
    }
}

local function unmark_pipeline(markers)
    if markers then
        for _ , entities in pairs(markers) do
            if entities.valid then
                entities.destroy()
            end
        end
    end
end

local function shift_in_direction(position_to_bump, current_direction, distance_to_shift)
    local position = position_to_bump
    if current_direction == defines.direction.north then
        position.y = position.y - distance_to_shift
        return position
    elseif current_direction == defines.direction.east then
        position.x = position.x + distance_to_shift
        return position
    elseif current_direction == defines.direction.west then
        position.x = position.x - distance_to_shift
        return position
    elseif current_direction == defines.direction.south then
        position.y = position.y + distance_to_shift
        return position
    end
end

local function highlight_pipeline(starter_entity, player_index)
    local player, pdata = Player.get(player_index)
    --? Declare working tables
    local read_entity_data = {true}
    --((
    local all_entities_marked = {}
    local all_markers = {}
    local tracked_orphans = {}

    --? Assign working table references to global reference under player
    pdata.current_marker_table = all_markers
    pdata.current_pipeline_table = all_entities_marked

    --? Setting and cache create entity function
    local max_pipes = settings.global['picker-max-checked-pipes'].value
    local current_surface_create = starter_entity.surface.create_entity

    --? Variables
    local orphan_counter = 0
    local pipes_read = 0
    local markers_made = 0

    local function draw_dot(position, type, current_direction, distance)
        markers_made = markers_made + 1
        all_markers[markers_made] = current_surface_create{
            name = pipe_highlight_markers.dot[type],
            position = shift_in_direction(position, current_direction, distance)
        }
    end

    local function draw_dash(position, type, current_direction, distance)
        markers_made = markers_made + 1
        game.print(pipe_highlight_markers.dash[type][current_direction])
        all_markers[markers_made] = current_surface_create{
            name = pipe_highlight_markers.dash[type][current_direction],
            position = shift_in_direction(position, current_direction, distance)
        }
    end
--))
    local function read_pipeline(entity, entity_unit_number, entity_name, entity_type, entity_position)
        local entity_neighbours = entity.neighbours[1]
        pipes_read = pipes_read + 1
        --read_entities[entity_unit_number] = true
        read_entity_data[entity_unit_number] =
            {
                -- 1
                entity,
                -- 2
                entity_unit_number,
                -- 3
                entity_name,
                -- 4
                entity_type,
                -- 5
                entity_position,
                -- 6
                entity_neighbours,
                -- 7
                #entity_neighbours
            }
        if #entity_neighbours < 2 then
            orphan_counter = orphan_counter + 1
            tracked_orphans[entity_unit_number] = true
        end
        if pipes_read < max_pipes then
            for _, neighbour in pairs(entity_neighbours) do
                local neighbour_type = neighbour.type
                local neighbour_name = neighbour.name
                local neighbour_position = neighbour.position
                local neighbour_unit_number = neighbour.unit_number
                if allowed_types[neighbour_type] and not not_allowed_names[neighbour_name] then
                    if not read_entity_data[neighbour_unit_number] then
                        read_pipeline(neighbour, neighbour_unit_number, neighbour_name, neighbour_type, neighbour_position)
                    end
                else
                    local current_direction = get_direction(entity_position, neighbour_position)
                    draw_dash(entity_position, 'good', current_direction, 0.5)
                    draw_dot(entity_position, 'good', current_direction, 0.5)
                    all_entities_marked[neighbour_unit_number] = true
                end
            end
        end
    end

    local starter_unit_number = starter_entity.unit_number
    local starter_entity_name = starter_entity.name
    local starter_entity_type = starter_entity.type
    local starter_entity_position = starter_entity.position
    read_pipeline(starter_entity, starter_unit_number, starter_entity_name, starter_entity_type, starter_entity_position)

    local function step_to_junction(entity_unit_number)
        local entity = read_entity_data[entity_unit_number]
        draw_dot(entity[5], 'bad', 0, 0)
        all_entities_marked[entity_unit_number] = true
        for _, neighbour in pairs(entity[6]) do
            local neighbour_unit_number = neighbour.unit_number
            local current_neighbour = read_entity_data[neighbour_unit_number]
            if current_neighbour then
                local current_direction = get_direction(entity[5], current_neighbour[5])
                if current_neighbour[7] < 3 and not all_entities_marked[neighbour_unit_number] then
                    draw_dash(entity[5], 'bad', current_direction, 0.5)
                    step_to_junction(neighbour_unit_number)
                end
            end
        end
    end

    if orphan_counter > 0 then
        for unit_number,_ in pairs(tracked_orphans) do
            local current_orphan = read_entity_data[unit_number]
            markers_made = markers_made + 1
            all_markers[markers_made] = current_surface_create{
                name = 'picker-pipe-marker-box-bad',
                position = current_orphan[5]
            }
            draw_dot(current_orphan[5], 'bad', 0, 0)
            all_entities_marked[unit_number] = true
            for _, neighbour in pairs(current_orphan[6]) do
                local neighbour_unit_number = neighbour.unit_number
                local current_neighbour = read_entity_data[neighbour_unit_number]
                if current_neighbour[7] < 3 and not all_entities_marked[neighbour_unit_number] then
                    local current_direction = get_direction(current_orphan[5], current_neighbour[5])
                    draw_dash(current_orphan[5], 'bad', current_direction, 0.5)
                    step_to_junction(neighbour_unit_number)
                end
            end
        end
    end
end




local function get_pipeline(event)
    local player, pdata = Player.get(event.player_index)
    if not pdata.current_pipeline_table then
        pdata.current_pipeline_table = {}
    end
    if not pdata.current_marker_table then
        pdata.current_marker_table = {}
    end
    local selection = player.selected
    --local last_entity = event.last_entity
    if selection then
        if allowed_types[selection.type] then
            if not pdata.current_pipeline_table[selection.unit_number] then
                unmark_pipeline(pdata.current_marker_table)
                pdata.current_pipeline_table = nil
                pdata.current_marker_table = nil
                highlight_pipeline(selection, event.player_index)
            end
        else
            unmark_pipeline(pdata.current_marker_table)
            pdata.current_pipeline_table = nil
            pdata.all_markers = nil
        end
    else
        unmark_pipeline(pdata.current_marker_table)
        pdata.current_pipeline_table = nil
        pdata.all_markers = nil
    end
end
Event.register('picker-highlight-pipeline', get_pipeline)

Event.register(defines.events.on_selected_entity_changed, get_pipeline)

--[[local function check_for_reassessment_mined(event)
    local _,pdata = Player.get(event.player_index)
    local entity = event.entity
    if pdata.current_pipeline_table and pdata.current_pipeline_table[entity.unit_number] then
        unmark_pipeline(pdata)
        pdata.current_pipeline_table = nil
        pdata.all_markers = nil
        highlight_pipeline(entity.neighbours[1][1], event.player_index, entity)
    end
end
Event.register(defines.events.on_player_mined_entity, check_for_reassessment_mined)

local function check_for_reassessment_built(event)
    local _,pdata = Player.get(event.player_index)
    local entity = event.created_entity
    for _ , entities in pairs(entity.neighbours) do
        for _, neighbour in pairs(entities) do
            if pdata.current_pipeline_table and pdata.current_pipeline_table[neighbour.unit_number] then
                unmark_pipeline(pdata)
                pdata.current_pipeline_table = nil
                pdata.all_markers = nil
                highlight_pipeline(entity, event.player_index)
            end
        end
    end
end
Event.register(defines.events.on_built_entity, check_for_reassessment_built)
]]--
