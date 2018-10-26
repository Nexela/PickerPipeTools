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
            local neighborCounter = 0
            local maxNeighbors = pipe_connections[entity.name] or 2
            for _, entities in pairs(entity.neighbours) do
                for _, neighbour in pairs(entities) do
                    neighborCounter = neighborCounter + 1
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
                if (maxNeighbors == neighborCounter) then
                    entity.surface.create_entity {
                        name = 'picker-pipe-marker-box-good',
                        position = entity.position
                    }
                elseif (neighborCounter < maxNeighbors) then
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

local allowed_types =
{
    ["pipe"] = true,
    ["pipe-to-ground"] = true,
    ["pump"] = true
}
local function recurse_pipeline(entity, tracked_entities)
    local tracked_entities = tracked_entities or {}
    if not tracked_entities[entity.unit_number] then
        tracked_entities[entity.unit_number] = entity
    end
    for _, entities in pairs(entity.neighbours) do
        for _, neighbour in pairs(entities) do
            if allowed_types[neighbour.type] and not tracked_entities[neighbour.unit_number] then
                tracked_entities[neighbour.unit_number] = neighbour
                recurse_pipeline(neighbour, tracked_entities)
            end
        end
    end
    return tracked_entities
end
local function highlight_pipeline(event)
    local player, _ = Player.get(event.player_index)
    local selection = player.selected
    if selection and allowed_types[selection.type] then
        local entities_to_highlight = recurse_pipeline(selection)
        for _ , entity in pairs(entities_to_highlight) do
            entity.surface.create_entity{
                name = 'picker-pipe-marker-box-good',
                position = entity.position
            }
        end
    end
end
Event.register('picker-highlight-pipeline', highlight_pipeline)
