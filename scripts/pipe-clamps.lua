local Event = require('__stdlib__/stdlib/event/event')

local clamped_name = {
    --1 =
    --2 =
    [3] = '-clamped-EW',
    --4 =
    [5] = '-clamped-NW',
    [6] = '-clamped-NE',
    [7] = '-clamped-NEW',
    --8 =
    [9] = '-clamped-SW',
    [10] = '-clamped-SE',
    [11] = '-clamped-SEW',
    [12] = '-clamped-NS',
    [13] = '-clamped-NSW',
    [14] = '-clamped-NSE'
    --[15] = "-clamped-nsew",
}

local yellow = defines.color.yellow
local green = defines.color.green
local red = defines.color.red

local function getEW(deltaX)
    return deltaX > 0 and 1 or 2
end

local function getNS(deltaY)
    return deltaY > 0 and 4 or 8
end

local function clamp_pipe(entity, player)
    local table_entry = 0
    local neighbour_count = 0
    for _, entities in pairs(entity.neighbours) do
        for _, neighbour in pairs(entities) do
            local deltaX = entity.position.x - neighbour.position.x
            local deltaY = entity.position.y - neighbour.position.y
            if deltaX ~= 0 and deltaY == 0 then
                table_entry = table_entry + getEW(deltaX)
                neighbour_count = neighbour_count + 1
            elseif deltaX == 0 and deltaY ~= 0 then
                table_entry = table_entry + getNS(deltaY)
                neighbour_count = neighbour_count + 1
            elseif deltaX ~=0 and deltaY ~= 0 then
                if math.abs(deltaX) > math.abs(deltaY) then
                    table_entry = table_entry + getEW(deltaX)
                elseif math.abs(deltaX) < math.abs(deltaY) then
                    table_entry = table_entry + getNS(deltaY)
                end
                neighbour_count = neighbour_count + 1
            end
        end
    end
    local pos = entity.position
    if neighbour_count > 1 and table_entry < 15 then
        entity.surface.create_entity {
                name = entity.name .. clamped_name[table_entry],
                position = pos,
                force = entity.force,
                fast_replace = true,
                player = player.index,
                spill = false
            }.last_user = player
        player.create_local_flying_text {
            position = pos,
            text = {'pipe-tools.clamped'},
            color = green
        }
        if entity then
            entity.destroy()
        end
    else
        player.create_local_flying_text {
            position = pos,
            text = {'pipe-tools.fail'},
            color = red
        }
    end
end

local function un_clamp_pipe(entity, player)
    local pos = entity.position
    entity.surface.create_entity {
            name = entity.prototype.mineable_properties.products[1].name,
            position = pos,
            force = entity.force,
            fast_replace = true,
            spill = false
        }.last_user = player
    player.create_local_flying_text {
        position = pos,
        text = {'pipe-tools.unclamped'},
        color = yellow
    }
    if entity then
        entity.destroy()
    end
end

local function toggle_pipe_clamp(event)
    local player = game.players[event.player_index]
    local selection = player.selected
    if selection and selection.type == 'pipe' and selection.force == player.force then
        local clamped = string.find(selection.name, '%-clamped%-')
        if not clamped and selection.name ~= '4-to-4-pipe' then
            clamp_pipe(selection, player)
        elseif clamped then
            un_clamp_pipe(selection, player)
        end
    end
end
Event.register('picker-toggle-pipe-clamp', toggle_pipe_clamp)

local function toggle_area_clamp(event)
    if event.item == 'picker-pipe-clamper' then
        local clamp = event.name == defines.events.on_player_selected_area
        local player = game.players[event.player_index]
        for _, entity in pairs(event.entities) do
            if entity.type == 'pipe' then
                local clamped = string.find(entity.name, '%-clamped%-')
                if clamp and not clamped and entity.name ~= '4-to-4-pipe' then
                    clamp_pipe(entity, player)
                elseif not clamp and clamped then
                    un_clamp_pipe(entity, player)
                end
            end
        end
    end
end
Event.register({defines.events.on_player_selected_area, defines.events.on_player_alt_selected_area}, toggle_area_clamp)
