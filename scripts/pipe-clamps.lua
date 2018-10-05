local Event = require('lib/event')
local Player = require('lib/player')

local clamped_name = {
    --[1] = "-clamped-none",
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

local function get_pipe(player_index)
    local player, pdata = Player.get(player_index)
    return (player.surface.find_entities_filtered{position = pdata.last_placed_pipe, type = 'pipe'})[1]
end

local function place_clamped_pipe(entity, table_entry, player, lock_pipe, failsafe)
    --local player, pdata = Player.get(player.index)
    local entity_position = entity.position
    local new
    if table_entry <= 15 and clamped_name[table_entry] then
        new = entity.surface.create_entity {
            name = entity.prototype.mineable_properties.products[1].name .. clamped_name[table_entry],
            position = entity_position,
            force = entity.force,
            fast_replace = true,
            spill = false
        }
        if not failsafe then
            new.surface.create_entity {
                name = 'flying-text',
                position = entity_position,
                text = {'advanced-pipe.clamped'},
                time_to_live = 60,
                speed = 1/60,
                color = green
            }
        elseif failsafe then
            new.surface.create_entity {
                name = 'flying-text',
                position = entity_position,
                text = {'advanced-pipe.clamped'},
                time_to_live = 60,
                speed = 1/60,
                color = yellow
            }
        end
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
                time_to_live = 120,
                color = red
            }
        end
    end
    return new
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

local function clamp_pipe(entity, player, lock_pipe, failsafe, reverse_entity)
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
    if neighbour_count > 0 then
        if reverse_entity then
            table_entry = table_entry - get_direction(entity, reverse_entity)
        end
        place_clamped_pipe(entity, table_entry, player, lock_pipe, failsafe)
    end
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
    --game.print("It's a pipe, we're gonna check it")
    --local pipe_to_place = 15
    local failsafe = false
    local entity = event.created_entity
    local player , pdata = Player.get(event.player_index)
    --game.print(serpent.line(entity.fluidbox[1]))
    local pipes_to_clamp = {}
    --[[local entity_fluidbox_name
    if entity.fluidbox[1] and entity.fluidbox[1].name then
        entity_fluidbox_name = entity.fluidbox[1].name
    else
        entity_fluidbox_name = false
    end]]--
    for _, entities in pairs(entity.neighbours) do
        for _, neighbour in pairs(entities) do
            --game.print("We're iterating neighbours on " .. entity.unit_number)
            local fluid_box_counter = 0
            --game.print("The neighbor fluidbox is " .. serpent.line(neighbour.fluidbox[1]))
            --game.print("The current entity fluidbox is " .. serpent.line(entity.fluidbox[1]))
            if neighbour.fluidbox[1] and neighbour.fluidbox[1].name and entity.fluidbox[1] and entity.fluidbox[1].name then
                if neighbour.fluidbox[1].name ~= entity.fluidbox[1].name then
                    --game.print("The fluid boxes don't match ")
                    --pipe_to_place = pipe_to_place - get_direction(neighbour, entity)
                    pipes_to_clamp[#pipes_to_clamp + 1] = neighbour
                    failsafe = true
                end
            elseif neighbour.fluidbox[1] and neighbour.fluidbox[1].name and not entity.fluidbox[1] then
                local last_pipe = get_pipe(event.player_index)
                if last_pipe and get_distance(entity, last_pipe) == 1 and last_pipe.fluidbox[1] and last_pipe.fluidbox[1].name then
                    --game.print("Last pipe's fluid box is: " .. serpent.line(last_pipe.fluidbox[1]))
                    if last_pipe.fluidbox[1].name ~= neighbour.fluidbox[1].name then
                        pipes_to_clamp[#pipes_to_clamp + 1] = neighbour
                        failsafe = true
                    end
                else
                    for _, subsequent_entities in pairs(neighbour.neighbours) do
                        for _, subsequent_neighbour in pairs(subsequent_entities) do
                            if subsequent_neighbour.unit_number ~= entity.unit_number then
                                if subsequent_neighbour.fluidbox[1] and subsequent_neighbour.fluidbox[1].name then
                                    fluid_box_counter = fluid_box_counter + 1
                                end
                            end
                        end
                        if fluid_box_counter > 1 then
                            --pipe_to_place = pipe_to_place - get_direction(neighbour, entity)
                            pipes_to_clamp[#pipes_to_clamp + 1] = neighbour
                            failsafe = true
                        end
                    end
                end
            end
        end
    end
    if failsafe then
        for _, entities in pairs(pipes_to_clamp) do
            clamp_pipe(entities, player, false, failsafe, entity)
        end
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
    pipe_failsafe_clamp({created_entity = new, player_index = player.index})
end

--[[local function get_opposite_direction(direction)
    if direction == 1 then
        return 2
    elseif direction == 2 then
        return 1
    elseif direction == 4 then
        return 8
    elseif direction == 8 then
        return 4
    end
end]]--

--[[local current_pipe_table =
{
    ["-clamped-none"] = {
        directions = {0},
    },
    ["-clamped-W"] = {
        directions = {1},
    },
    ["-clamped-E"] = {
        directions = {2},
    },
    ["-clamped-EW"] = {
        directions = {1, 2},
    },
    ["-clamped-N"] = {
        directions = {4},
    },
    ["-clamped-NW"] = {
        directions = {1, 4},
    },
    ["-clamped-NE"] = {
        directions = {2, 4},
    },
    ["-clamped-NEW"] = {
        directions = {1, 2, 4},
    },
    ["-clamped-S"] = {
        directions = {8},
    },
    ["-clamped-SW"] = {
        directions = {1, 8},
    },
    ["-clamped-SE"] = {
        directions = {2, 8},
    },
    ["-clamped-SEW"] = {
        directions = {1, 2, 8},
    },
    ["-clamped-NS"] = {
        directions = {4, 8},
    },
    ["-clamped-NSW"] = {
        directions = {1, 4, 8},
    },
    ["-clamped-NSE"] = {
        directions = {2, 4, 8},
    },
    ["-clamped-NSEW"] = {
        directions = {1, 2, 4, 8},
    },
}]]--

--[[local function get_new_pipe(name, direction)
    for names, directions in pairs(current_pipe_table) do
        if string.find(name, names) then
            if directions[direction] and not directions ~= {0} then
                local adder
                for number in directions do
                    adder = adder + number
                end
                --game.print("New pipe is already connected" .. adder)
                return adder
            else
                local adder
                for number in directions do
                    adder = adder + number
                end
                adder = adder + direction
                --game.print("new pipe is adding connection as" .. adder)
                return adder
            end
        end
    end
end]]--
--Still fixing this area
--[[local function controlled_pipe_placement(event)
    local player , pdata = Player.get(event.player_index)
    if not pdata.controlled_mode then
        return
    end
    local entity = event.created_entity
    if pdata and pdata.last_placed_pipe then
        local last_entity = (player.surface.find_entities_filtered{position = pdata.last_placed_pipe, type = 'pipe'})[1]
        if get_distance(entity, last_entity) == 1 then
            local direction_from_current = get_direction(entity, last_entity)
            local reverse_direction = get_opposite_direction(direction_from_current)
            local current_new_pipe = get_new_pipe(entity.name, direction_from_current)
            local previous_new_pipe = get_new_pipe(last_entity.name, reverse_direction)
            --game.print(previous_new_pipe .. " is the previous new pipe")
            local new_pipe = place_clamped_pipe(entity, current_new_pipe, player)
            pdata.last_placed_pipe = new_pipe.position
            place_clamped_pipe(last_entity, previous_new_pipe, player)
        else
            local new_pipe = place_clamped_pipe(entity, 0, player)
            pdata.last_placed_pipe = new_pipe.position
        end
    else
        local new_pipe = place_clamped_pipe(entity, 0, player)
        pdata.last_placed_pipe = new_pipe.position
    end
end]]--



--[[local function controlled_pipe_placement_toggle(event)
    local player , pdata = Player.get(event.player_index)
    if pdata.controlled_mode then
        pdata.controlled_mode = false
        player.print("Controlled mode off")
    else
        pdata.controlled_mode = true
        player.print("Controlled mode on")
    end
end
Event.register('picker-controlled-pipe-toggle', controlled_pipe_placement_toggle)]]--

local function toggle_pipe_clamp(event)
    local player, _ = Player.get(event.player_index)
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
            if entity.valid and entity.type == 'pipe' then --Verify entity still exists. Un_clamp fires pipe_failsafe_clamp which may replace an entity in the event.entities table
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


local function on_built_entity(event)
    if event.created_entity and event.created_entity.type == 'pipe' then
        local _, pdata = Player.get(event.player_index)
        local position_to_save = event.created_entity.position
        pipe_failsafe_clamp(event)
        pdata.last_placed_pipe = position_to_save
    end
end
Event.register(defines.events.on_built_entity, on_built_entity)
