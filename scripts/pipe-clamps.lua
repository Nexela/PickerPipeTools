-------------------------------------------------------------------------------
--[[Pipe Clamps]] --
-------------------------------------------------------------------------------
-- Concept designed and code written by TheStaplergun (staplergun on mod portal)

local Event = require('lib/event')
local Player = require('lib/player')

--[[defines.direction.north     == 0    1
defines.direction.east     == 2         4
defines.direction.south     == 4        16
defines.direction.west     == 6         64
]]

local clamped_name = {
    --[1] = "-clamped-none",
    [1] = "-clamped-N",
    [4] = "-clamped-E",
    [5] = "-clamped-NE",
    [16] = "-clamped-S",
    [17] = "-clamped-NS",
    [20] = "-clamped-SE",
    [21] = "-clamped-NSE",
    [64] = "-clamped-W",
    [65] = "-clamped-NW",
    [68] = "-clamped-EW",
    [69] = "-clamped-NEW",
    [80] = "-clamped-SW",
    [81] = "-clamped-NSW",
    [84] = "-clamped-SEW",
    [85] = "-clamped-NSEW",
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
    return deltaX > 0 and defines.direction.west or defines.direction.east
end

local function getNS(deltaY)
    return deltaY > 0 and defines.direction.north or defines.direction.south
end

local function get_last_pipe(player_index)
    local player, pdata = Player.get(player_index)
    local pipe = (player.surface.find_entities_filtered{position = pdata.last_placed_pipe, type = 'pipe'})[1]
    local return_data = {entity = pipe, unit_number = false, fluid_name = "none"}
    if pipe then
        if pipe.fluidbox[1] and pipe.fluidbox[1].name then
            return_data.fluid_name = pipe.fluidbox[1].name
        end
        return_data.unit_number = pipe.unit_number
    end
    return return_data
end

local function get_pipe_info(entity)
    local return_data = {pipe = entity, fluid_name = "none"}
    if entity.fluidbox[1] and entity.fluidbox[1].name then
        return_data.fluid_name = entity.fluidbox[1].name
    end
    return return_data
end
local function place_clamped_pipe(entity, table_entry, player, lock_pipe, failsafe)
    --local player, pdata = Player.get(player.index)
    local entity_position = entity.position
    local new
    if table_entry <= 85 and clamped_name[table_entry] then
        new = entity.surface.create_entity {
            name = entity.prototype.mineable_properties.products[1].name .. clamped_name[table_entry],
            position = entity_position,
            force = entity.force,
            fast_replace = true,
            spill = false
        }
        if failsafe then
            new.surface.create_entity {
                name = 'flying-text',
                position = entity_position,
                text = {'pipe-tools.clamped'},
                time_to_live = 60,
                speed = 1/60,
                color = yellow
            }
        else
            new.surface.create_entity {
                name = 'flying-text',
                position = entity_position,
                text = {'pipe-tools.clamped'},
                time_to_live = 60,
                speed = 1/60,
                color = green
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
                text = {'pipe-tools.fail'},
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
        table_entry = table_entry + 2^(getEW(deltaX))
    elseif deltaX == 0 and deltaY ~= 0 then
        --game.print("It's a y difference")
        table_entry = table_entry + 2^(getNS(deltaY))
    elseif deltaX ~=0 and deltaY ~= 0 then
        if math.abs(deltaX) > math.abs(deltaY) then
            --game.print("They're both different but x is larger")
            table_entry = table_entry + 2^(getEW(deltaX))
        elseif math.abs(deltaX) < math.abs(deltaY) then
            --game.print("They're both different but y is larger")
            table_entry = table_entry + 2^(getNS(deltaY))
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
                table_entry = table_entry + 2^(getEW(deltaX))
                neighbour_count = neighbour_count + 1
            elseif deltaX == 0 and deltaY ~= 0 then
                table_entry = table_entry + 2^(getNS(deltaY))
                neighbour_count = neighbour_count + 1
            elseif deltaX ~= 0 and deltaY ~= 0 then
                if math.abs(deltaX) > math.abs(deltaY) then
                    table_entry = table_entry + 2^(getEW(deltaX))
                elseif math.abs(deltaX) < math.abs(deltaY) then
                    table_entry = table_entry + 2^(getNS(deltaY))
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
    if not neighbour then
        return 0
    end
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

local function pipe_failsafe_clamp(event, unclamp)
    local failsafe = false
    local entity = event.created_entity
    local player , pdata = Player.get(event.player_index)
    local pipes_to_clamp = {}

    local current_pipe_data = get_pipe_info(entity)
    local current_fluid = current_pipe_data.fluid_name

    local last_pipe_data = get_last_pipe(event.player_index)
    local last_pipe = last_pipe_data.entity
    local last_pipe_unit_number = last_pipe_data.unit_number
    local last_pipe_fluid = last_pipe_data.fluid_name

    for _, entities in pairs(entity.neighbours) do
        for _, neighbour in pairs(entities) do
            if neighbour.type == 'pipe' then
                local neighbour_data = get_pipe_info(neighbour)
                local neighbour_fluid_name = neighbour_data.fluid_name
                if (unclamp and neighbour_fluid_name ~= current_fluid and neighbour_fluid_name ~= "none" and current_fluid ~= "none") or (neighbour_fluid_name ~= current_fluid and neighbour_fluid_name ~= "none" and current_fluid ~= "none") then
                    pipes_to_clamp[#pipes_to_clamp + 1] = neighbour
                    failsafe = true
                elseif not unclamp and last_pipe_unit_number ~= neighbour.unit_number and not pdata.auto_clamp_mode_off then
                    if get_distance(entity, last_pipe) == 1 and last_pipe_fluid ~= neighbour_fluid_name then
                        pipes_to_clamp[#pipes_to_clamp + 1] = neighbour
                        failsafe = true
                    else
                        local fluid_box_counter = 0
                        for _, subsequent_entities in pairs(neighbour.neighbours) do
                            for _, subsequent_neighbour in pairs(subsequent_entities) do
                                if subsequent_neighbour.unit_number ~= entity.unit_number then
                                    fluid_box_counter = fluid_box_counter + 1
                                end
                            end
                            if fluid_box_counter > 1 then
                                pipes_to_clamp[#pipes_to_clamp + 1] = neighbour
                                failsafe = true
                            end
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
    pipe_failsafe_clamp({created_entity = new, player_index = player.index}, true)
end

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
        if not pdata.last_placed_pipe then
            pdata.last_placed_pipe = position_to_save
        end
            pipe_failsafe_clamp(event, false)
        pdata.last_placed_pipe = position_to_save
    end
end
Event.register(defines.events.on_built_entity, on_built_entity)

local function toggle_auto_clamp(event)
    local player, pdata = Player.get(event.player_index)
    if pdata.auto_clamp_mode_off then
        pdata.auto_clamp_mode_off = false
        player.print({"pipe-tools.auto-clamp-on"})
    else
        pdata.auto_clamp_mode_off = true
        player.print({"pipe-tools.auto-clamp-off"})
    end
end
Event.register("picker-auto-clamp-toggle", toggle_auto_clamp)