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
                                player.surface.create_entity {
                                    name = 'picker-underground-pipe-marker-horizontal',
                                    position = {entity.position.x + i, entity.position.y}
                                }
                            end
                        end
                        if (entity.position.y - neighbour.position.y) < -1.5 then
                            local distancey = neighbour.position.y - entity.position.y
                            for i = 1, distancey - 1, 1 do
                                player.surface.create_entity {
                                    name = 'picker-underground-pipe-marker-vertical',
                                    position = {entity.position.x, entity.position.y + i}
                                }
                            end
                        end
                    end
                end
                if (maxNeighbors == neighbour_count) then
                    entity.surface.create_entity {
                        name = 'picker-pipe-marker-box-good',
                        position = entity.position
                    }
                elseif (neighbour_count < maxNeighbors) then
                    entity.surface.create_entity {
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

local function get_direction(entity, neighbour)
    if not entity.valid or not neighbour.valid then
        return
    end
    local delta_x = entity.position.x - neighbour.position.x
    local delta_y = entity.position.y - neighbour.position.y
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
local pipe_highlight_markers = {
    ["normal"] = {
        [defines.direction.north] = 'picker-pipe-marker-ns',
        [defines.direction.east] = 'picker-pipe-marker-ew',
        [defines.direction.west] = 'picker-pipe-marker-ew',
        [defines.direction.south] = 'picker-pipe-marker-ns',
    },
    ["good"] = {
        [defines.direction.north] = 'picker-pipe-marker-good-ns',
        [defines.direction.east] = 'picker-pipe-marker-good-ew',
        [defines.direction.west] = 'picker-pipe-marker-good-ew',
        [defines.direction.south] = 'picker-pipe-marker-good-ns',
    },
    ["bad"] = {
        [defines.direction.north] = 'picker-pipe-marker-bad-ns',
        [defines.direction.east] = 'picker-pipe-marker-bad-ew',
        [defines.direction.west] = 'picker-pipe-marker-bad-ew',
        [defines.direction.south] = 'picker-pipe-marker-bad-ns',
    }
}

local function draw_underground_sprites(entity, neighbour, type)
    local entity_position = entity.position
    local neighbour_position = neighbour.position
    local delta_x = (entity_position.x - neighbour_position.x)
    local delta_y = (entity_position.y - neighbour_position.y)
    local current_direction = get_direction(entity, neighbour)
    local entities_to_return = {}
    if delta_x < 0 then
        local distance_x = (neighbour_position.x - entity_position.x)
        for i = 0.5, distance_x, 1 do
            entities_to_return[#entities_to_return + 1] = entity.surface.create_entity {
                name = pipe_highlight_markers[type][current_direction],
                position = {entity_position.x + i, entity_position.y}
            }
        end
        return entities_to_return
    elseif delta_x > 0 then
        for i = 0.5, delta_x, 1 do
            entities_to_return[#entities_to_return + 1] = entity.surface.create_entity {
                name = pipe_highlight_markers[type][current_direction],
                position = {entity_position.x - i, entity_position.y}
            }
        end
        return entities_to_return
    elseif delta_y < 0 then
        local distance_y = (neighbour_position.y - entity_position.y)
        for i = 0.5, distance_y, 1 do
            entities_to_return[#entities_to_return + 1] = entity.surface.create_entity {
                name = pipe_highlight_markers[type][current_direction],
                position = {entity_position.x, entity_position.y + i}
            }
        end
        return entities_to_return
    elseif delta_y > 0 then
        for i = 0.5, delta_y, 1 do
            entities_to_return[#entities_to_return + 1] = entity.surface.create_entity {
                name = pipe_highlight_markers[type][current_direction],
                position = {entity_position.x, entity_position.y - i}
            }
        end
        return entities_to_return
    end
end

local function shift_in_direction(current_direction, position, distance_to_shift)
    if current_direction == defines.direction.north then
        return {position.x, position.y - distance_to_shift}
    elseif current_direction == defines.direction.east then
        return {position.x + distance_to_shift, position.y}
    elseif current_direction == defines.direction.west then
        return {position.x - distance_to_shift, position.y}
    elseif current_direction == defines.direction.south then
        return {position.x, position.y + distance_to_shift}
    end
end


local function unmark_pipeline(pdata)
    if pdata.current_marker_table then
        for _ , entity in pairs(pdata.current_marker_table) do
            if entity.valid then
                entity.destroy()
            end
        end
    end
end

--[[local marker_name_table = {
    'picker-pipe-marker-ns',
    'picker-pipe-marker-ew',
    'picker-pipe-marker-ew',
    'picker-pipe-marker-ns',
    'picker-pipe-marker-good-ns',
    'picker-pipe-marker-good-ew',
    'picker-pipe-marker-good-ew',
    'picker-pipe-marker-good-ns',
    'picker-pipe-marker-bad-ns',
    'picker-pipe-marker-bad-ew',
    'picker-pipe-marker-bad-ew',
    'picker-pipe-marker-bad-ns',
    'picker-pipe-dot-bad',
    'picker-pipe-dot',
    'picker-pipe-dot-good',
}]]--
local function highlight_pipeline(starter_pipe, player_index, entity_not_to_mark)
    local player, pdata = Player.get(player_index)
    --local selection = player.selected
    local all_entities_read = {[starter_pipe.unit_number] = starter_pipe}
    local all_markers = {}
    pdata.current_marker_table = all_markers
    pdata.current_pipeline_table = all_entities_read
    local marked_entities = {}
    if entity_not_to_mark then
        marked_entities[entity_not_to_mark.unit_number] = true
    end
    local tracked_orphans = {}
    local tracked_bad_branch = {}
    local orphan_counter = 0
    local args = {position = {}}
    local last_pipe
    local max_pipes = settings.global['picker-max-checked-pipes'].value
    local pipes_read = 0
    local function recurse_to_junction(entity)
        local entity_position = entity.position
        local entity_unit_number = entity.unit_number
        all_markers[#all_markers + 1] = entity.surface.create_entity {
            name = 'picker-pipe-dot-bad',
            position = entity_position
        }
        marked_entities[entity_unit_number] = true
        for _ , entities in pairs(entity.neighbours) do
            for _, neighbour in pairs(entities) do
                if neighbour ~= entity_not_to_mark and pipes_read <= max_pipes then
                    local neighbours_neighbour_count = #neighbour.neighbours[1]
                    local current_direction = get_direction(entity, neighbour)
                    local neighbour_type = neighbour.type
                    local neighbour_unit_number = neighbour.unit_number
                    if allowed_types[neighbour_type]
                    and (neighbours_neighbour_count < 3)
                    and not tracked_bad_branch[neighbour_unit_number] then
                        tracked_bad_branch[entity_unit_number] = true
                        --tracked_bad_branch[neighbour_unit_number] = true
                        --marked_entities[neighbour_unit_number] = truea
                        if entity.type == 'pipe-to-ground' and neighbour_type == 'pipe-to-ground' or (neighbour_type == 'pump' and neighbour.name == 'underground-mini-pump') then
                            local underground_markers = draw_underground_sprites(entity, neighbour, "bad")
                            for _, markers in pairs(underground_markers) do
                                all_markers[#all_markers + 1] = markers
                            end
                        else
                            local neighbour_position = neighbour.position
                            args.position[1] = (entity_position.x + neighbour_position.x)/2
                            args.position[2] = (entity_position.y + neighbour_position.y)/2
                            args.name = pipe_highlight_markers['bad'][current_direction]
                            all_markers[#all_markers + 1] = entity.surface.create_entity(args)
                        end
                        recurse_to_junction(neighbour)
                    elseif allowed_types[neighbour_type] and not (neighbours_neighbour_count < 3) then
                        --marked_entities[entity.unit_number] = true
                        local neighbour_position = neighbour.position
                        args.position[1] = (entity_position.x + neighbour_position.x)/2
                        args.position[2] = (entity_position.y + neighbour_position.y)/2
                        args.name = pipe_highlight_markers['bad'][current_direction]
                        all_markers[#all_markers + 1] = entity.surface.create_entity(args)
                    end
                end
            end
        end
    end
    local function read_pipeline(entity)
        local entity_position = entity.position
        for _ , entities in pairs(entity.neighbours) do
            local neighbour_count = #entities
            for _, neighbour in pairs(entities) do
                if neighbour ~= entity_not_to_mark and pipes_read <= max_pipes then
                    local current_direction = get_direction(entity, neighbour)
                    local neighbour_type = neighbour.type
                    local neighbour_unit_number = neighbour.unit_number
                    local max_neighbours = pipe_connections[entity.name] or 2
                    if ((neighbour_count < 2 and entity.type == 'pipe') or (neighbour_count < max_neighbours)) then
                        orphan_counter = orphan_counter + 1
                        all_markers[#all_markers + 1] = entity.surface.create_entity {
                            name = 'picker-pipe-marker-box-bad',
                            position = entity_position
                        }
                        tracked_orphans[entity.unit_number] = entity
                    end
                    if allowed_types[neighbour_type] and not all_entities_read[neighbour_unit_number] then
                        all_entities_read[neighbour_unit_number] = neighbour
                        pipes_read = pipes_read + 1
                        read_pipeline(neighbour)
                    elseif not allowed_types[neighbour_type] then
                        local position_to_place = shift_in_direction(current_direction, entity_position, 0.5)
                        args.position = position_to_place
                        args.name = pipe_highlight_markers['good'][current_direction]
                        all_markers[#all_markers + 1] = entity.surface.create_entity(args)
                        position_to_place = shift_in_direction(current_direction, entity_position, 1)
                        args.position = position_to_place
                        args.name = 'picker-pipe-dot-good'
                        all_markers[#all_markers + 1] = entity.surface.create_entity(args)
                    end
                elseif neighbour == entity_not_to_mark and #neighbour.neighbours < 2 then
                    orphan_counter = orphan_counter + 1
                    all_markers[#all_markers + 1] = entity.surface.create_entity {
                        name = 'picker-pipe-marker-box-bad',
                        position = entity_position
                    }
                    tracked_orphans[entity.unit_number] = entity
                end
            end
        end
    end
    read_pipeline(starter_pipe)
    if orphan_counter > 0 then
        for _, entity in pairs(tracked_orphans) do
            recurse_to_junction(entity)
        end
        for _, entity in pairs(all_entities_read) do
            local entity_unit_number = entity.unit_number
            if not marked_entities[entity_unit_number] then
                local entity_position = entity.position
                all_markers[#all_markers + 1] = entity.surface.create_entity {
                    name = 'picker-pipe-dot',
                    position = entity_position
                }
                marked_entities[entity_unit_number] = true
                last_pipe = entity
                for _ , entities in pairs(entity.neighbours) do
                    for _, neighbour in pairs(entities) do
                        local current_direction = get_direction(entity, neighbour)
                        local neighbour_type = neighbour.type
                        local neighbour_unit_number = neighbour.unit_number
                        if allowed_types[neighbour_type] and not marked_entities[neighbour_unit_number] and not tracked_bad_branch[neighbour_unit_number] then
                            --marked_entities[neighbour_unit_number] = true
                            if entity.type == 'pipe-to-ground' and neighbour_type == 'pipe-to-ground' or (neighbour_type == 'pump' and neighbour.name == 'underground-mini-pump') then
                                local underground_markers = draw_underground_sprites(entity, neighbour, "normal")
                                for _, markers in pairs(underground_markers) do
                                    all_markers[#all_markers + 1] = markers
                                end
                            else
                                local neighbour_position = neighbour.position
                                args.position[1] = (entity_position.x + neighbour_position.x)/2
                                args.position[2] = (entity_position.y + neighbour_position.y)/2
                                args.name = pipe_highlight_markers["normal"][current_direction]
                                all_markers[#all_markers + 1] = entity.surface.create_entity(args)
                            end
                        elseif allowed_types[neighbour_type] and marked_entities[neighbour_unit_number] and neighbour ~= last_pipe then
                            local neighbour_position = neighbour.position
                            args.position[1] = (entity_position.x + neighbour_position.x)/2
                            args.position[2] = (entity_position.y + neighbour_position.y)/2
                            args.name = pipe_highlight_markers["normal"][current_direction]
                            all_markers[#all_markers + 1] = entity.surface.create_entity(args)
                        end
                    end
                end
            end
        end
        game.print(orphan_counter .. " dead end pipes detected")
    else
        for _, entity in pairs(all_entities_read) do
            local entity_position = entity.position
            local entity_unit_number = entity.unit_number
            all_markers[#all_markers + 1] = entity.surface.create_entity {
                name = 'picker-pipe-dot-good',
                position = entity_position
            }
            last_pipe = entity
            marked_entities[entity_unit_number] = true
            for _ , entities in pairs(entity.neighbours) do
                for _, neighbour in pairs(entities) do
                    local current_direction = get_direction(entity, neighbour)
                    local neighbour_type = neighbour.type
                    local neighbour_unit_number = neighbour.unit_number
                    if allowed_types[neighbour_type] and not marked_entities[neighbour_unit_number] then

                        --marked_entities[neighbour_unit_number] = true
                        if entity.type == 'pipe-to-ground' and neighbour_type == 'pipe-to-ground' or (neighbour_type == 'pump' and neighbour.name == 'underground-mini-pump') then
                            local underground_markers = draw_underground_sprites(entity, neighbour, "good")
                            for _, markers in pairs(underground_markers) do
                                all_markers[#all_markers + 1] = markers
                            end
                        else
                            local neighbour_position = neighbour.position
                            args.position[1] = (entity_position.x + neighbour_position.x)/2
                            args.position[2] = (entity_position.y + neighbour_position.y)/2
                            args.name = pipe_highlight_markers["good"][current_direction]
                            all_markers[#all_markers + 1] = entity.surface.create_entity(args)
                        end
                    elseif allowed_types[neighbour_type] and marked_entities[neighbour_unit_number] and neighbour ~= last_pipe then
                        local neighbour_position = neighbour.position
                        args.position[1] = (entity_position.x + neighbour_position.x)/2
                        args.position[2] = (entity_position.y + neighbour_position.y)/2
                        args.name = pipe_highlight_markers["good"][current_direction]
                        all_markers[#all_markers + 1] = entity.surface.create_entity(args)
                    end
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
    if not pdata.all_markers then
        pdata.all_markers = {}
    end
    local selection = player.selected
    local last_entity = event.last_entity
    --[[if selection and allowed_types[selection.type] and pdata.current_pipeline_table and pdata.current_pipeline_table[selection.unit_number] then
        unmark_pipeline(pdata)
        pdata.current_pipeline_table = nil
        pdata.all_markers = nil
    else]]if selection and allowed_types[selection.type] and pdata.current_pipeline_table and not pdata.current_pipeline_table[selection.unit_number] then
        unmark_pipeline(pdata)
        pdata.current_pipeline_table = nil
        pdata.all_markers = nil
        highlight_pipeline(selection, event.player_index, false)
    elseif selection and allowed_types[selection.type] and not pdata.current_pipeline_table then
        highlight_pipeline(selection, event.player_index, false)
    elseif selection and not allowed_types[selection.type] and pdata.current_pipeline_table then
        unmark_pipeline(pdata)
        pdata.current_pipeline_table = nil
        pdata.all_markers = nil
    elseif not selection and pdata.current_pipeline_table then
        unmark_pipeline(pdata)
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
