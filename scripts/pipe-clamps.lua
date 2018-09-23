local Event = require('__stdlib__/stdlib/event/event')

local clamped_name = {
    --1 =
    --2 =
    [3] = '-clamped-ew',
    --4 =
    [5] = '-clamped-nw',
    [6] = '-clamped-ne',
    [7] = '-clamped-new',
    --8 =
    [9] = '-clamped-sw',
    [10] = '-clamped-se',
    [11] = '-clamped-sew',
    [12] = '-clamped-ns',
    [13] = '-clamped-nsw',
    [14] = '-clamped-nse'
    --[15] = "-clamped-nsew",
}

local yellow = defines.color.yellow
local green = defines.color.green
local red = defines.color.red

local function clamp_pipe(entity, player)
    local table_entry = 0
    local neighbour_count = 0
    for _, entities in pairs(entity.neighbours) do
        for _, neighbour in pairs(entities) do
            if (entity.position.x - neighbour.position.x) > 0 then
                --west
                table_entry = table_entry + 1
                neighbour_count = neighbour_count + 1
            end
            if (entity.position.x - neighbour.position.x) < 0 then
                --east
                table_entry = table_entry + 2
                neighbour_count = neighbour_count + 1
            end
            if (entity.position.y - neighbour.position.y) > 0 then
                --north
                table_entry = table_entry + 4
                neighbour_count = neighbour_count + 1
            end
            if (entity.position.y - neighbour.position.y) < 0 then
                --south
                table_entry = table_entry + 8
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
