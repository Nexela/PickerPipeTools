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
--? Working on the recursive check.

local function getEW(deltaX)
    return deltaX > 0 and defines.direction.west or defines.direction.east
end

local function getNS(deltaY)
    return deltaY > 0 and defines.direction.north or defines.direction.south
end

local function get_direction(entity, neighbour)
    if not entity.valid or not neighbour.valid then
        return
    end
    local deltaX = entity.position.x - neighbour.position.x
    local deltaY = entity.position.y - neighbour.position.y
    if deltaX ~= 0 and deltaY == 0 then
        return getEW(deltaX)
    elseif deltaX == 0 and deltaY ~= 0 then
        return getNS(deltaY)
    elseif deltaX ~= 0 and deltaY ~= 0 then
        if math.abs(deltaX) > math.abs(deltaY) then
            return getEW(deltaX)
        elseif math.abs(deltaX) < math.abs(deltaY) then
            return getNS(deltaY)
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
    if delta_x < -1.5 then
        local distance_x = (neighbour_position.x - entity_position.x)
        for i = 0.5, distance_x, 1 do
            entity.surface.create_entity {
                name = pipe_highlight_markers[type][current_direction],
                position = {entity_position.x + i, entity_position.y}
            }
        end
    elseif delta_x > 1.5 then
        for i = 0.5, delta_x, 1 do
            entity.surface.create_entity {
                name = pipe_highlight_markers[type][current_direction],
                position = {entity_position.x - i, entity_position.y}
            }
        end
    elseif delta_y < -1.5 then
        local distance_y = (neighbour_position.y - entity_position.y)
        for i = 0.5, distance_y, 1 do
            entity.surface.create_entity {
                name = pipe_highlight_markers[type][current_direction],
                position = {entity_position.x, entity_position.y + i}
            }
        end
    elseif delta_y > 1.5 then
        for i = 0.5, delta_y, 1 do
            entity.surface.create_entity {
                name = pipe_highlight_markers[type][current_direction],
                position = {entity_position.x, entity_position.y - i}
            }
        end
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

local function highlight_pipeline(event)
    local player, _ = Player.get(event.player_index)
    local selection = player.selected
    if selection and allowed_types[selection.type] then
        local all_entities_read = {[selection.unit_number] = selection}
        local marked_entities = {}
        local tracked_orphans = {}
        local tracked_bad_branch = {}
        local orphan_counter = 0
        local args = {position = {}}
        local function recurse_to_junction(entity)
            local entity_position = entity.position
            entity.surface.create_entity {
                name = 'picker-pipe-dot-bad',
                position = entity_position
            }
            for _ , entities in pairs(entity.neighbours) do
                for _, neighbour in pairs(entities) do
                    local neighbours_neighbour_count = #neighbour.neighbours[1]
                    local current_direction = get_direction(entity, neighbour)
                    local neighbour_type = neighbour.type
                    local neighbour_unit_number = neighbour.unit_number
                    if allowed_types[neighbour_type]
                    and (neighbours_neighbour_count < 3)
                    and not tracked_bad_branch[neighbour_unit_number] then
                        tracked_bad_branch[neighbour_unit_number] = true
                        all_entities_read[neighbour_unit_number] = nil
                        if entity.type == 'pipe-to-ground' and neighbour_type == 'pipe-to-ground' or (neighbour_type == 'pump' and neighbour.name == 'underground-mini-pump') then
                            draw_underground_sprites(entity, neighbour, "bad")
                        else
                            local neighbour_position = neighbour.position
                            args.position[1] = (entity_position.x + neighbour_position.x)/2
                            args.position[2] = (entity_position.y + neighbour_position.y)/2
                            args.name = pipe_highlight_markers['bad'][current_direction]
                            entity.surface.create_entity(args)
                        end
                        recurse_to_junction(neighbour)
                    elseif allowed_types[neighbour_type] and not (neighbours_neighbour_count < 3) then
                        marked_entities[entity.unit_number] = true
                        local neighbour_position = neighbour.position
                        args.position[1] = (entity_position.x + neighbour_position.x)/2
                        args.position[2] = (entity_position.y + neighbour_position.y)/2
                        args.name = pipe_highlight_markers['bad'][current_direction]
                        entity.surface.create_entity(args)
                    end
                end
            end
        end
        local function read_pipeline(entity)
            local entity_position = entity.position
            for _ , entities in pairs(entity.neighbours) do
                local neighbour_count = #entities
                for _, neighbour in pairs(entities) do
                    local current_direction = get_direction(entity, neighbour)
                    local neighbour_type = neighbour.type
                    local neighbour_unit_number = neighbour.unit_number
                    local max_neighbours = pipe_connections[entity.name] or 2
                    if (neighbour_count < 2 and entity.type == 'pipe') or (neighbour_count < max_neighbours) then
                        orphan_counter = orphan_counter + 1
                        entity.surface.create_entity {
                            name = 'picker-pipe-marker-box-bad',
                            position = entity_position
                        }
                        tracked_orphans[entity.unit_number] = entity
                    end
                    if allowed_types[neighbour_type] and not all_entities_read[neighbour_unit_number] then
                        all_entities_read[neighbour_unit_number] = neighbour
                        read_pipeline(neighbour)
                    elseif not allowed_types[neighbour_type] then
                        local position_to_place = shift_in_direction(current_direction, entity_position, 0.5)
                        args.position = position_to_place
                        args.name = pipe_highlight_markers['good'][current_direction]
                        entity.surface.create_entity(args)
                        position_to_place = shift_in_direction(current_direction, entity_position, 1)
                        args.position = position_to_place
                        args.name = 'picker-pipe-dot-good'
                        entity.surface.create_entity(args)
                    end
                end
            end
        end
        read_pipeline(selection)
        if orphan_counter > 0 then
            for _, entity in pairs(tracked_orphans) do
                recurse_to_junction(entity)
            end
            for _, entity in pairs(all_entities_read) do
                local entity_position = entity.position
                entity.surface.create_entity {
                    name = 'picker-pipe-dot',
                    position = entity_position
                }
                for _ , entities in pairs(entity.neighbours) do
                    for _, neighbour in pairs(entities) do
                        local current_direction = get_direction(entity, neighbour)
                        local neighbour_type = neighbour.type
                        local neighbour_unit_number = neighbour.unit_number
                        if allowed_types[neighbour_type] and not marked_entities[neighbour_unit_number] and not tracked_bad_branch[neighbour_unit_number] then
                            marked_entities[neighbour_unit_number] = true
                            if entity.type == 'pipe-to-ground' and neighbour_type == 'pipe-to-ground' or (neighbour_type == 'pump' and neighbour.name == 'underground-mini-pump') then
                                draw_underground_sprites(entity, neighbour, "normal")
                            else
                                local neighbour_position = neighbour.position
                                args.position[1] = (entity_position.x + neighbour_position.x)/2
                                args.position[2] = (entity_position.y + neighbour_position.y)/2
                                args.name = pipe_highlight_markers["normal"][current_direction]
                                entity.surface.create_entity(args)
                            end
                        end
                    end
                end
            end
            game.print(orphan_counter .. " dead end pipes detected")
        else
            for _, entity in pairs(all_entities_read) do
                local entity_position = entity.position
                entity.surface.create_entity {
                    name = 'picker-pipe-dot-good',
                    position = entity_position
                }
                for _ , entities in pairs(entity.neighbours) do
                    for _, neighbour in pairs(entities) do
                        local current_direction = get_direction(entity, neighbour)
                        local neighbour_type = neighbour.type
                        local neighbour_unit_number = neighbour.unit_number
                        if allowed_types[neighbour_type] and not marked_entities[neighbour_unit_number] then
                            marked_entities[neighbour_unit_number] = true
                            if entity.type == 'pipe-to-ground' and neighbour_type == 'pipe-to-ground' or (neighbour_type == 'pump' and neighbour.name == 'underground-mini-pump') then
                                draw_underground_sprites(entity, neighbour, "good")
                            else
                                local neighbour_position = neighbour.position
                                args.position[1] = (entity_position.x + neighbour_position.x)/2
                                args.position[2] = (entity_position.y + neighbour_position.y)/2
                                args.name = pipe_highlight_markers["good"][current_direction]
                                entity.surface.create_entity(args)
                            end
                        end
                    end
                end
            end
        end
    end
end


Event.register('picker-highlight-pipeline', highlight_pipeline)
