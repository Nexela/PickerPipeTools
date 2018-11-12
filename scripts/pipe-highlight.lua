-------------------------------------------------------------------------------
--[[Pipe Highlighter]] --
-------------------------------------------------------------------------------
-- Concept designed and code written by TheStaplergun (staplergun on mod portal)
-- STDLib and code reviews provided by Nexela

local Player = require('lib/player')
local Event = require('lib/event')
local Position = require('lib/position')

local pipe_connections = {}
local function load_pipe_connections()
    if remote.interfaces['underground-pipe-pack'] then
        pipe_connections = remote.call('underground-pipe-pack', 'get_pipe_table')
    end
end
Event.register({Event.core_events.init, Event.core_events.load}, load_pipe_connections)

local function show_underground_sprites(event)
    local player = game.players[event.player_index]
    local create = player.surface.create_entity
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
                                player.surface {
                                    name = 'picker-underground-pipe-marker-horizontal',
                                    position = {entity.position.x + i, entity.position.y}
                                }
                            end
                        end
                        if (entity.position.y - neighbour.position.y) < -1.5 then
                            local distancey = neighbour.position.y - entity.position.y
                            for i = 1, distancey - 1, 1 do
                                player.surface {
                                    name = 'picker-underground-pipe-marker-vertical',
                                    position = {entity.position.x, entity.position.y + i}
                                }
                            end
                        end
                    end
                end
                if (maxNeighbors == neighbour_count) then
                    create {
                        name = 'picker-pipe-marker-box-good',
                        position = entity.position
                    }
                elseif (neighbour_count < maxNeighbors) then
                    create {
                        name = 'picker-pipe-marker-box-bad',
                        position = entity.position
                    }
                end
            end
        end
    end
end
Event.register('picker-show-underground-paths', show_underground_sprites)

local directional_table = {
    [0] = '',
    [1] = '-n',
    [4] = '-e',
    [5] = '-ne',
    [16] = '-s',
    [17] = '-ns',
    [20] = '-se',
    [21] = '-nse',
    [64] = '-w',
    [65] = '-nw',
    [68] = '-ew',
    [69] = '-new',
    [80] = '-sw',
    [81] = '-nsw',
    [84] = '-sew',
    [85] = '-nsew'
}

--? Tables for read-limits
local allowed_types = {
    ['pipe'] = true,
    ['pipe-to-ground'] = true,
    ['pump'] = true
}

local not_allowed_names = {
    ['factory-fluid-dummy-connector'] = true,
    ['factory-fluid-dummy-connector-south'] = true
}

--? Table for types and names to draw dashes between
local draw_dashes_types = {
    ['pipe-to-ground'] = true
}
local draw_dashes_names = {
    ['underground-mini-pump'] = true
}

local pipe_highlight_markers = {
    dash = {
        ['normal'] = {
            [defines.direction.north] = 'picker-pipe-marker-ns',
            [defines.direction.east] = 'picker-pipe-marker-ew',
            [defines.direction.west] = 'picker-pipe-marker-ew',
            [defines.direction.south] = 'picker-pipe-marker-ns'
        },
        ['good'] = {
            [defines.direction.north] = 'picker-pipe-marker-good-ns',
            [defines.direction.east] = 'picker-pipe-marker-good-ew',
            [defines.direction.west] = 'picker-pipe-marker-good-ew',
            [defines.direction.south] = 'picker-pipe-marker-good-ns'
        },
        ['bad'] = {
            [defines.direction.north] = 'picker-pipe-marker-bad-ns',
            [defines.direction.east] = 'picker-pipe-marker-bad-ew',
            [defines.direction.west] = 'picker-pipe-marker-bad-ew',
            [defines.direction.south] = 'picker-pipe-marker-bad-ns'
        }
    },
    dot = {
        ['normal'] = 'picker-pipe-dot',
        ['good'] = 'picker-pipe-dot-good',
        ['bad'] = 'picker-pipe-dot-bad'
    },
    beam = {
        ['normal'] = 'picker-pipe-marker-beam',
        ['good'] = 'picker-pipe-marker-beam-good',
        ['bad'] = 'picker-pipe-marker-beam-bad',
    }
}

local function unmark_pipeline(markers)
    if markers then
        for _, entity in pairs(markers) do
            entity.destroy()
        end
    end
end

local function get_ew(delta_x)
    return delta_x > 0 and defines.direction.west or defines.direction.east
end

local function get_ns(delta_y)
    return delta_y > 0 and defines.direction.north or defines.direction.south
end

local function get_direction(entity_position, neighbour_position)
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

local function highlight_pipeline(starter_entity, player_index)
    local player, pdata = Player.get(player_index)
    --? Declare working tables
    local read_entity_data = {}
    local all_entities_marked = {}
    local all_markers = {}
    local tracked_orphans = {}

    --? Assign working table references to global reference under player
    pdata.current_marker_table = all_markers
    pdata.current_pipeline_table = all_entities_marked

    --? Setting and cache create entity function
    -- TODO max_pipes can be cached at the TLD and updated in settings changed event
    local max_pipes = settings.global['picker-max-checked-pipes'].value
    local create = starter_entity.surface.create_entity

    --? Variables
    local orphan_counter = 0
    local pipes_read = 0
    local markers_made = 0

    local function draw_marker(position, type, directions)
        markers_made = markers_made + 1
        all_markers[markers_made] =
            create {
            name = pipe_highlight_markers.dot[type] .. directional_table[directions],
            position = position
        }
    end

    --? Handles drawing dashes between two pipe to ground.
    local function draw_dashes(entity_position, neighbour_position, type)
        markers_made = markers_made + 1
        all_markers[markers_made] =
            create {
            name = pipe_highlight_markers.beam[type],
            position = entity_position,
            source_position = {entity_position.x, entity_position.y + 0.9},
            target_position = {neighbour_position.x, neighbour_position.y - 0.1},
            duration = 2000000000
        }
    end

    local function get_directions(entity_position, entity_neighbours)
        local table_entry = 0
        for _, neighbour in pairs(entity_neighbours) do
            local neighbour_unit_number = neighbour.unit_number
            local current_neighbour = read_entity_data[neighbour_unit_number]
            if current_neighbour then
                table_entry = table_entry + (2 ^ get_direction(entity_position, current_neighbour[1]))
            else
                table_entry = table_entry + (2 ^ get_direction(entity_position, neighbour.position))
            end
        end
        return table_entry
    end

    --? Gather and cache pipeline info.
    local function read_pipeline(entity, entity_unit_number, entity_position, entity_type, entity_name)
        local entity_neighbours = entity.neighbours[1]
        pipes_read = pipes_read + 1
        --? Stored as indexed array internally.
        read_entity_data[entity_unit_number] = {
            entity_position,
            entity_neighbours,
            entity_type,
            entity_name
        }
        --? Checks for orphahns
        if #entity_neighbours < 2 then
            orphan_counter = orphan_counter + 1
            tracked_orphans[entity_unit_number] = true
        end
        --? Ensures reading and marking no more than maximum pipes per the setting.
        if pipes_read < max_pipes then
            for _, neighbour in pairs(entity_neighbours) do
                --? Pre-cache all data
                local neighbour_type = neighbour.type
                local neighbour_name = neighbour.name
                local neighbour_position = neighbour.position
                local neighbour_unit_number = neighbour.unit_number
                --? Make sure we stick with pipes/pumps and don't read disallowed names (Such as factorissimo)
                if allowed_types[neighbour_type] and not not_allowed_names[neighbour_name] then
                    --? Verify we haven't been here before
                    if not read_entity_data[neighbour_unit_number] then
                        --? Step to next pipe
                        read_pipeline(neighbour, neighbour_unit_number, neighbour_position, neighbour_type, neighbour_name)
                    end
                else --? Mark objects that aren't allowed to be traversed to. (Endpoints such as storage-tank, oil-refinery, etc.)
                    local current_direction = get_direction(entity_position, neighbour_position)
                    draw_marker(Position.translate(entity_position, current_direction, 1), 'good', 2 ^ Position.opposite_direction(current_direction))
                    all_entities_marked[neighbour_unit_number] = true
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

    local function step_to_junction(entity_unit_number)
        --? Grab cached data. Removes need for API calls alltogether at this stage.
        local entity = read_entity_data[entity_unit_number]
        draw_marker(entity[1], 'bad', get_directions(entity[1], entity[2]))
        all_entities_marked[entity_unit_number] = true
        for _, neighbour in pairs(entity[2]) do
            local neighbour_unit_number = neighbour.unit_number
            local current_neighbour = read_entity_data[neighbour_unit_number]
            if current_neighbour then
                if #current_neighbour[2] < 3 and not all_entities_marked[neighbour_unit_number] then
                    if draw_dashes_types[entity[3]] or draw_dashes_names[entity[4]] then
                        if draw_dashes_types[current_neighbour[3]] or draw_dashes_names[current_neighbour[4]] then
                            draw_dashes(entity[1], current_neighbour[1], 'bad')
                        end
                    end
                    step_to_junction(neighbour_unit_number)
                end
            end
        end
    end

    if orphan_counter > 0 then
        player.print(orphan_counter .. ' dead end pipes found.')
        for unit_number, _ in pairs(tracked_orphans) do
            local current_orphan = read_entity_data[unit_number]
            markers_made = markers_made + 1
            all_markers[markers_made] =
                create {
                name = 'picker-pipe-marker-box-bad',
                position = current_orphan[1]
            }
            draw_marker(current_orphan[1], 'bad', get_directions(current_orphan[1], current_orphan[2]))
            all_entities_marked[unit_number] = true
            for _, neighbour in pairs(current_orphan[2]) do
                local neighbour_unit_number = neighbour.unit_number
                local current_neighbour = read_entity_data[neighbour_unit_number]
                if current_neighbour then
                    if #current_neighbour[2] < 3 and not all_entities_marked[neighbour_unit_number] then
                        if draw_dashes_types[current_orphan[3]] or draw_dashes_names[current_orphan[4]] then
                            if draw_dashes_types[current_neighbour[3]] or draw_dashes_names[current_neighbour[4]] then
                                draw_dashes(current_orphan[1], current_neighbour[1], 'bad')
                            end
                        end
                        step_to_junction(neighbour_unit_number)
                    end
                end
            end
        end
        for unit_number, current_entity in pairs(read_entity_data) do
            if not all_entities_marked[unit_number] then
                if draw_dashes_types[current_entity[3]] or draw_dashes_names[current_entity[4]] then
                    for _, neighbour in pairs(current_entity[2]) do
                        local neighbour_unit_number = neighbour.unit_number
                        local current_neighbour = read_entity_data[neighbour_unit_number]
                        if current_neighbour and (draw_dashes_types[current_neighbour[3]] or draw_dashes_names[current_neighbour[4]]) and not all_entities_marked[neighbour_unit_number] then
                            --[[markers_made = markers_made + 1
                            all_markers[markers_made] =
                                create {
                                name = 'picker-pipe-marker-beam',
                                position = current_entity[1],
                                source_position = {current_entity[1].x, current_entity[1].y + 0.9},
                                target_position = {current_neighbour[1].x, current_neighbour[1].y - 0.1},
                                duration = 2000000000
                            }]]--
                            draw_dashes(current_entity[1], current_neighbour[1], 'normal')
                        end
                    end
                end
                draw_marker(current_entity[1], 'normal', get_directions(current_entity[1], current_entity[2]))
                all_entities_marked[unit_number] = true
            end
        end
    else
        for unit_number, current_entity in pairs(read_entity_data) do
            if not all_entities_marked[unit_number] then
                if draw_dashes_types[current_entity[3]] or draw_dashes_names[current_entity[4]] then
                    for _, neighbour in pairs(current_entity[2]) do
                        local neighbour_unit_number = neighbour.unit_number
                        local current_neighbour = read_entity_data[neighbour_unit_number]
                        if current_neighbour and (draw_dashes_types[current_neighbour[3]] or draw_dashes_names[current_neighbour[4]]) then
                            draw_dashes(current_entity[1], current_neighbour[1], 'good')
                        end
                    end
                end
                draw_marker(current_entity[1], 'good', get_directions(current_entity[1], current_entity[2]))
                all_entities_marked[unit_number] = true
            end
        end
    end
    game.print(pipes_read .. " pipes found in currently selected network")
end

local function get_pipeline(event)
    local player, pdata = Player.get(event.player_index)
    pdata.current_pipeline_table = pdata.current_pipeline_table or {}
    pdata.current_marker_table = pdata.current_marker_table or {}

    local selection = player.selected
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

Event.register({'picker-highlight-pipeline', defines.events.on_selected_entity_changed}, get_pipeline)
