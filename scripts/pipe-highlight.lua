--[[
-- "name": "underground-pipe-pack",
-- "title": "Advanced Underground Piping",
-- "author": "TheStaplergun",
-- "contact": "TheStaplergun 2.0#6920 (DISCORD)",
-- "description": "Adds new functionality to underground piping.",
--]]
local Event = require('__stdlib__/stdlib/event/event')
local Position = require('__stdlib__/stdlib/area/position')

local pipetable = {
    ['one-to-one-forward-pipe'] = 2,
    ['one-to-one-right-pipe'] = 2,
    ['one-to-one-left-pipe'] = 2,
    ['one-to-one-reverse-pipe'] = 2,
    ['pipe-to-ground'] = 2,
    ['one-to-two-parallel-pipe'] = 3,
    ['one-to-two-perpendicular-pipe'] = 3,
    ['one-to-two-L-FL-pipe'] = 3,
    ['one-to-two-L-FR-pipe'] = 3,
    ['one-to-two-L-RR-pipe'] = 3,
    ['one-to-two-L-RL-pipe'] = 3,
    ['underground-i-pipe'] = 2,
    ['underground-L-pipe'] = 2,
    ['underground-mini-pump'] = 2,
    ['one-to-three-forward-pipe'] = 4,
    ['one-to-three-right-pipe'] = 4,
    ['one-to-three-reverse-pipe'] = 4,
    ['one-to-three-left-pipe'] = 4,
    ['underground-t-pipe'] = 3,
    ['one-to-four-pipe'] = 5,
    ['underground-cross-pipe'] = 4
}

local function show_underground_sprites(event)
    local player = game.players[event.player_index]
    for _, entity in pairs(player.surface.find_entities_filtered {area = Position.expand_to_area(player.position, 64), type = 'pipe-to-ground'}) do
        local neighborCounter = 0
        local maxNeighbors = pipetable[entity.name] or 2
        for _, entities in pairs(entity.neighbours) do
            for _, neighbour in pairs(entities) do
                local pos = Position(entity.position)
                neighborCounter = neighborCounter + 1
                if (entity.position.x - neighbour.position.x) < -1.5 then
                    local distancex = neighbour.position.x - entity.position.x
                    for i = 1, distancex - 1, 1 do
                        entity.surface.create_entity {
                            name = 'picker-underground-marker-horizontal',
                            position = pos:copy():offset(i, 0)
                        }
                    end
                end
                if (entity.position.y - neighbour.position.y) < -1.5 then
                    local distancey = neighbour.position.y - entity.position.y
                    for i = 1, distancey - 1, 1 do
                        player.surface.create_entity {
                            name = 'picker-underground-marker-vertical',
                            position = pos:copy():offset(0, i)
                        }
                    end
                end
            end
            if (maxNeighbors == neighborCounter) then
                entity.surface.create_entity {
                    name = 'picker-marker-box-green',
                    position = entity.position
                }
            elseif (neighborCounter < maxNeighbors) then
                entity.surface.create_entity {
                    name = 'picker-marker-box-red',
                    position = entity.position
                }
            end
        end
    end
end
Event.register('picker-show-underground-paths', show_underground_sprites)
