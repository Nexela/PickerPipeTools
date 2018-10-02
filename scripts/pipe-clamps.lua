local Event = require('lib/event')

local clamped_name = {
    [0] = "-clamped",
    [1] = "-clamped-W",
    [2] = "-clamped-E",
    [3] = "-clamped-EW",
    [4] = "-clamped-N",
    [5] = "-clamped-NW",
    [6] = "-clamped-NE",
    [7] = "-clamped-NEW",
    [8] = "-clamped-S",
    [9] = "-clamped-SW",
    [10] = "-clamped-SE",
    [11] = "-clamped-SEW",
    [12] = "-clamped-NS",
    [13] = "-clamped-NSW",
    [14] = "-clamped-NSE",
    [15] = "-clamped-NSEW",
}

local yellow = {r = 1, g = 1}
local green = {g = 1}
local red = {r = 1}

local ignore_pipes = {}
local function load_pipe_connections()
    if remote.interfaces['underground-pipe-pack'] then
        ignore_pipes = remote.call('underground-pipe-pack', 'get_ignored_pipes')
    end
end
Event.register({Event.core_events.init, Event.core_events.load}, load_pipe_connections)

local function getEW(deltaX)
    return deltaX > 0 and 1 or 2
end

local function getNS(deltaY)
    return deltaY > 0 and 4 or 8
end

local function place_clamped_pipe(entity, table_entry, player, lock_pipe)
    local entity_position = entity.position
    local new
    if table_entry <= 15 and clamped_name[table_entry] then
        new = entity.surface.create_entity {
            name = entity.name .. clamped_name[table_entry],
            position = entity_position,
            force = entity.force,
            fast_replace = true,
            spill = false
        }
        new.surface.create_entity {
            name = 'flying-text',
            position = entity_position,
            text = {'advanced-pipe.clamped'},
            color = green
        }
        new.last_user = player
        if entity then
            entity.destroy()
        end
    else
        if lock_pipe then
            entity.surface.create_entity {
                name = 'flying-text',
                position = entity_position,
                text = {'advanced-pipe.fail'},
                color = red
            }
        end
    end
    return new
end

local function clamp_pipe(entity, player, lock_pipe)
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
            elseif deltaX ~= 0 and deltaY ~= 0 then
                if math.abs(deltaX) > math.abs(deltaY) then
                    table_entry = table_entry + getEW(deltaX)
                elseif math.abs(deltaX) < math.abs(deltaY) then
                    table_entry = table_entry + getNS(deltaY)
                end
                neighbour_count = neighbour_count + 1
            end
        end
    end
    if neighbour_count > 1 then
        place_clamped_pipe(entity, table_entry, player, lock_pipe)
    end
end

local function un_clamp_pipe(entity, player)
    local pos = entity.position
    local new =
        entity.surface.create_entity {
        name = entity.prototype.mineable_properties.products[1].name,
        position = pos,
        force = entity.force,
        fast_replace = true,
        spill = false
    }
    new.surface.create_entity {
        name = 'flying-text',
        position = pos,
        text = {'pipe-tools.unclamped'},
        color = yellow
    }
    new.last_user = player
    if entity then
        entity.destroy()
    end
end

local function get_direction(entity, neighbour)
    local table_entry = 0
    local deltaX = entity.position.x - neighbour.position.x
    local deltaY = entity.position.y - neighbour.position.y
    if deltaX ~= 0 and deltaY == 0 then
        --game.print("It's a x difference")
        table_entry = table_entry + getEW(deltaX)
    elseif deltaX == 0 and deltaY ~= 0 then
        --game.print("It's a y difference")
        table_entry = table_entry + getNS(deltaY)
    elseif deltaX ~=0 and deltaY ~= 0 then
        if math.abs(deltaX) > math.abs(deltaY) then
            --game.print("They're both different but x is larger")
            table_entry = table_entry + getEW(deltaX)
        elseif math.abs(deltaX) < math.abs(deltaY) then
            --game.print("They're both different but y is larger")
            table_entry = table_entry + getNS(deltaY)
        end
    end
    return table_entry
end

local function get_distance(entity, neighbour)
    local deltaX = math.abs(entity.position.x - neighbour.position.x)
    local deltaY = math.abs(entity.position.y - neighbour.position.y)
    if deltaX ~= 0 and deltaY == 0 then
        return deltaX
    elseif deltaX == 0 and deltaY ~= 0 then
        return deltaY
    elseif deltaX ~=0 and deltaY ~= 0 then
        return math.sqrt(((deltaX ^ 2) + (deltaY ^ 2)))
    end
end

local function pipe_failsafe_clamp(event)
    game.print("It's a pipe, we're gonna check it")
    local pipe_to_place = 15
    local failsafe = false
    local entity = event.created_entity
    --local pipes_to_clamp = {}
    --[[local entity_fluidbox_name
    if entity.fluidbox[1] and entity.fluidbox[1].name then
        entity_fluidbox_name = entity.fluidbox[1].name
    end]]--
    --local neighbour_fluidbox_names = {}
    for _, entities in pairs(entity.neighbours) do
        for _, neighbour in pairs(entities) do
            game.print("We're iterating neighbours on " .. entity.unit_number)
            local fluid_box_counter = 0
            if neighbour.fluidbox[1] and neighbour.fluidbox[1].name then
                --[[local fluid_name = neighbour.fluidbox[1].name
                if not neighbour_fluidbox_names[fluid_name] then
                    neighbour_fluidbox_names[fluid_name] = {
                        name = fluid_name,
                        count = 0,
                        direction = 0
                    }
                end
                neighbour_fluidbox_names[fluid_name].count = neighbour_fluidbox_names[fluid_name].count + 1
                neighbour_fluidbox_names[fluid_name].direction = neighbour_fluidbox_names[fluid_name].direction + get_direction(entity, neighbour)]]--
                for _, subsequent_entities in pairs(neighbour.neighbours) do
                    for _, subsequent_neighbour in pairs(subsequent_entities) do
                        if subsequent_neighbour.unit_number ~= entity.unit_number then
                            if subsequent_neighbour.fluidbox[1] and subsequent_neighbour.fluidbox[1].name then
                                fluid_box_counter = fluid_box_counter + 1
                            end
                        end
                    end
                end
                if fluid_box_counter > 1 then
                    pipe_to_place = pipe_to_place - get_direction(entity, neighbour)
                    failsafe = true
                end
            end
        end
    end
    if failsafe then
        local player = game.players[event.player_index]
        place_clamped_pipe(entity, pipe_to_place, player)
        --[[local name_count_tracker = 0
        local most_common = {}
        for _ , names in pairs(neighbour_fluidbox_names) do
            if names.count > name_count_tracker then
                name_count_tracker = names.count
                most_common = names.name
            end
        end
        place_clamped_pipe(entity, neighbour_fluidbox_names[most_common].direction, player)]]--
        --place_clamped_pipe(entity, pipe_to_place, player)
        --[[for _, entities in pairs(pipes_to_clamp) do
            clampPipe(entities, player)
        end]]--
    end
end

local function controlled_pipe_placement(event)
    local player = game.players[event.player_index]
    if not global[player].controlled_mode then
        return
    end
    local entity = event.created_entity
    if global[player] and global[player].last_placed_pipe then
        local last_entity = global[player].last_placed_pipe
        if get_distance(entity, last_entity) == 1 then
            local direction_from_current = get_direction(entity, last_entity)

        else
            local new_pipe = place_clamped_pipe(entity, 0, player)
            global[player].last_placed_pipe = new_pipe
        end
    else
        local new_pipe = place_clamped_pipe(entity, 0, player)
        global[player].last_placed_pipe = new_pipe
    end
end

local function toggle_pipe_clamp(event)
    local player = game.players[event.player_index]
    local selection = player.selected
    local lock_pipe = true
    if selection and selection.type == 'pipe' and selection.force == player.force then
        local clamped = string.find(selection.name, '%-clamped%-')
        if not clamped and not ignore_pipes[selection.name] then
            clamp_pipe(selection, player, lock_pipe)
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
                if clamp and not clamped and not ignore_pipes[entity.name] then
                    clamp_pipe(entity, player)
                elseif not clamp and clamped then
                    un_clamp_pipe(entity, player)
                end
            end
        end
    end
end
Event.register({defines.events.on_player_selected_area, defines.events.on_player_alt_selected_area}, toggle_area_clamp)

script.on_event(defines.events.on_built_entity, function(event)
    local player = game.players[event.player_index]
    if event.created_entity and event.created_entity.type == 'pipe' then
        if global[player].controlled_mode then
            controlled_pipe_placement(event)
        else
            pipe_failsafe_clamp(event)
        end
    end
end)


script.on_event(defines.events.on_player_joined_game, function(player_index)
    local player = game.players[player_index]
    global[player] = global[player] or {
        controlled_mode = false,
        last_placed_pipe = {}
    }
end)
