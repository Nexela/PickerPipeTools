--[[
-- "name": "underground-pipe-pack",
-- "title": "Advanced Underground Piping",
-- "author": "TheStaplergun",
-- "contact": "TheStaplergun 2.0#6920 (DISCORD)",
-- "description": "Adds new functionality to underground piping.",
--]]
local Event = require('__stdlib__/stdlib/event/event')
local Position = require('__stdlib__/stdlib/area/position')

local pipe_connections = {}
local function load_pipe_connections()
    if remote.interfaces['underground-pipe-pack'] then
        pipe_connections = remote.call('underground-pipe-pack', 'get_pipe_table')
    end
end
Event.register({Event.core_events.init, Event.core_events.load}, load_pipe_connections)

-- TODO check placement for existing highlight-box
local function show_underground_sprites(event)
    local player = game.players[event.player_index]
    for _, entity in pairs(player.surface.find_entities_filtered {area = Position.expand_to_area(player.position, 64), type = 'pipe-to-ground'}) do
        local neighborCounter = 0
        local maxNeighbors = pipe_connections[entity.name] or 2
        for _, entities in pairs(entity.neighbours) do
            for _, neighbour in pairs(entities) do
                local pos = Position(entity.position)
                neighborCounter = neighborCounter + 1

                if (entity.position.x - neighbour.position.x) < -1.5 then
                    local distancex = neighbour.position.x - entity.position.x
                    for i = 1, distancex - 1, 1 do
                        entity.surface.create_entity {
                            name = 'picker-highlight-box',
                            position = entity.position, -- pos:offset(i, 0)
                            bounding_box = pos:offset(i, 0):expand_to_area(.5),
                            render_player_index = player.index,
                            box_type = 'train-visualization',
                            time_to_live = 60 * 10,
                            blink_interval = 0
                        }
                    end
                end if (entity.position.y - neighbour.position.y) < -1.5 then
                    local distancey = neighbour.position.y - entity.position.y
                    for i = 1, distancey - 1, 1 do
                        entity.surface.create_entity {
                            name = 'picker-highlight-box',
                            position = entity.position, -- pos:offset(i, 0)
                            bounding_box = pos:offset(0, i):expand_to_area(.5),
                            render_player_index = player.index,
                            box_type = 'train-visualization',
                            time_to_live = 60 * 10,
                            blink_interval = 0
                        }
                    end
                end
            end
            if (maxNeighbors == neighborCounter) then
                entity.surface.create_entity {
                    name = 'picker-highlight-box',
                    position = entity.position,
                    target = entity,
                    render_player_index = player.index,
                    box_type = 'copy',
                    time_to_live = 60 * 10,
                    blink_interval = 0
                }
            elseif (neighborCounter < maxNeighbors) then
                entity.surface.create_entity {
                    name = 'picker-highlight-box',
                    position = entity.position,
                    target = entity,
                    render_player_index = player.index,
                    box_type = 'not-allowed',
                    time_to_live = 60 * 10
                }
            end
        end
    end
end
Event.register('picker-show-underground-paths', show_underground_sprites)
