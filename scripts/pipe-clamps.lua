-------------------------------------------------------------------------------
--[[Pipe Clamps]] --
-------------------------------------------------------------------------------
-- Concept designed and code written by TheStaplergun (staplergun on mod portal)
-- STDLib and code reviews provided by Nexela

local Event = require('lib/event')
local Player = require('lib/player')

--[[defines.direction.north     == 0    1
defines.direction.east     == 2         4
defines.direction.south     == 4        16
defines.direction.west     == 6         64
]]

local map_clamped_name = {
    --[0] = "-clamped-none",
    ['-clamped-N'] = {
        name = '-clamped-single',
        direction = defines.direction.north
    },
    ['-clamped-E'] = {
        name = '-clamped-single',
        direction = defines.direction.east
    },
    ['-clamped-NE'] = {
        name = '-clamped-l',
        direction = defines.direction.east
    },
    ['-clamped-S'] = {
        name = '-clamped-single',
        direction = defines.direction.south
    },
    ['-clamped-NS'] = {
        name = '-clamped-i',
        direction = defines.direction.north
    },
    ['-clamped-SE'] = {
        name = '-clamped-l',
        direction = defines.direction.south
    },
    ['-clamped-NSE'] = {
        name = '-clamped-t',
        direction = defines.direction.east
    },
    ['-clamped-W'] = {
        name = '-clamped-single',
        direction = defines.direction.west
    },
    ['-clamped-NW'] = {
        name = '-clamped-l',
        direction = defines.direction.north
    },
    ['-clamped-EW'] = {
        name = '-clamped-i',
        direction = defines.direction.east
    },
    ['-clamped-NEW'] = {
        name = '-clamped-t',
        direction = defines.direction.north
    },
    ['-clamped-SW'] = {
        name = '-clamped-l',
        direction = defines.direction.west
    },
    ['-clamped-NSW'] = {
        name = '-clamped-t',
        direction = defines.direction.west
    },
    ['-clamped-SEW'] = {
        name = '-clamped-t',
        direction = defines.direction.south
    },
    ['-clamped-NSEW'] = {
        name = '-clamped-x',
        direction = defines.direction.north
    }
}

local clamped_name = {
    --[0] = "-clamped-none",
    [1] = '-clamped-N',
    [4] = '-clamped-E',
    [5] = '-clamped-NE',
    [16] = '-clamped-S',
    [17] = '-clamped-NS',
    [20] = '-clamped-SE',
    [21] = '-clamped-NSE',
    [64] = '-clamped-W',
    [65] = '-clamped-NW',
    [68] = '-clamped-EW',
    [69] = '-clamped-NEW',
    [80] = '-clamped-SW',
    [81] = '-clamped-NSW',
    [84] = '-clamped-SEW',
    [85] = '-clamped-NSEW'
}

local clamped_name_match = {
    --[0] = "-clamped-none",
    [1] = '%-clamped%-N$',
    [4] = '%-clamped%-E$',
    [5] = '%-clamped%-NE$',
    [16] = '%-clamped%-S$',
    [17] = '%-clamped%-NS$',
    [20] = '%-clamped%-SE$',
    [21] = '%-clamped%-NSE$',
    [64] = '%-clamped%-W$',
    [65] = '%-clamped%-NW$',
    [68] = '%-clamped%-EW$',
    [69] = '%-clamped%-NEW$',
    [80] = '%-clamped%-SW$',
    [81] = '%-clamped%-NSW$',
    [84] = '%-clamped%-SEW$',
    [85] = '%-clamped%-NSEW$'
}

local function migrate_clamped_pipes()
    local counter = 0
    for _,surface in pairs(game.surfaces) do
        for _,pipe in pairs(surface.find_entities_filtered({type = 'pipe'})) do
            --local migrated = false
            if string.find(pipe.name, "%-clamped%-") then
                for table_entry,old_name in pairs(clamped_name) do
                    local is_match = string.find(pipe.name, clamped_name_match[table_entry])
                    if is_match then
                        pipe.surface.create_entity {
                            name = pipe.prototype.mineable_properties.products[1].name .. map_clamped_name[clamped_name[table_entry]].name,
                            position = pipe.position,
                            direction = map_clamped_name[clamped_name[table_entry]].direction,
                            force = pipe.force,
                            fast_replace = true,
                            spill = false
                        }
                        counter = counter + 1
                        --migrated = true
                        break
                    end
                end
            end
        end
    end
    game.print(counter .. " clamps migrated to new pipes. Old clamped pipes have been removed. (Blueprints with them will still contain them.)")
end
script.on_configuration_changed(migrate_clamped_pipes)

local not_clampable_pipes = {
    ['4-to-4-pipe'] = true,
    ['factory-fluid-dummy-connector'] = true,
    ['factory-fluid-dummy-connector-south'] = true,
}
local yellow = {r = 1, g = 1}
local green = {g = 1}
local red = {r = 1}

local function getEW(deltaX)
    return deltaX > 0 and defines.direction.west or defines.direction.east
end

local function getNS(deltaY)
    return deltaY > 0 and defines.direction.north or defines.direction.south
end

-- can return nil or entity
local function get_last_pipe(player, pdata)
    return pdata.last_pipe_position and (player.surface.find_entities_filtered {position = pdata.last_pipe_position, type = 'pipe'})[1]
end

-- returns a table which may or may not have contents if entity passed is nil
local function get_pipe_info(entity)
    local data = {}
    if entity and entity.valid then
        local box = entity.fluidbox[1]
        data.entity = entity
        data.fluid_name = box and box.name
    end
    return data
end

--((
-- Clamping and Unclamping need to check for for a filter and add it to the replaced pipe
local function place_clamped_pipe(entity, table_entry, player, lock_pipe, autoclamp)
    --local player, pdata = Player.get(player.index)
    local entity_position = entity.position
    local new
    if table_entry <= 85 and clamped_name[table_entry] then
        local filter_table = entity.fluidbox.get_filter(1)
        local event_data = {
            entity = entity,
            player_index = player.index
        }
        script.raise_event(defines.events.script_raised_destroy, event_data)
        new =
            entity.surface.create_entity {
            name = entity.prototype.mineable_properties.products[1].name .. map_clamped_name[clamped_name[table_entry]].name,
            position = entity_position,
            direction = map_clamped_name[clamped_name[table_entry]].direction,
            force = entity.force,
            fast_replace = true,
            spill = false
        }
        if not autoclamp then
            new.surface.create_entity {
                name = 'flying-text',
                position = entity_position,
                text = {'pipe-tools.clamped'},
                time_to_live = 60,
                color = green
            }
        end
        new.last_user = player
        new.fluidbox.set_filter(1, filter_table)
        local event = {
            created_entity = new,
            player_index = player.index,
            clamped = true
        }
        script.raise_event(defines.events.script_raised_built, event)
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
    if not entity.valid or not neighbour.valid then
        return
    end
    local deltaX = entity.position.x - neighbour.position.x
    local deltaY = entity.position.y - neighbour.position.y
    if deltaX ~= 0 and deltaY == 0 then
        table_entry = table_entry + 2 ^ (getEW(deltaX))
    elseif deltaX == 0 and deltaY ~= 0 then
        table_entry = table_entry + 2 ^ (getNS(deltaY))
    elseif deltaX ~= 0 and deltaY ~= 0 then
        if math.abs(deltaX) > math.abs(deltaY) then
            table_entry = table_entry + 2 ^ (getEW(deltaX))
        elseif math.abs(deltaX) < math.abs(deltaY) then
            table_entry = table_entry + 2 ^ (getNS(deltaY))
        end
    end
    return table_entry
end

local function clamp_pipe(entity, player, lock_pipe, autoclamp, reverse_entity)
    local table_entry = 0
    local neighbour_count = 0
    for _, entities in pairs(entity.neighbours) do
        for _, neighbour in pairs(entities) do
            local deltaX = entity.position.x - neighbour.position.x
            local deltaY = entity.position.y - neighbour.position.y
            if deltaX ~= 0 and deltaY == 0 then
                table_entry = table_entry + 2 ^ (getEW(deltaX))
                neighbour_count = neighbour_count + 1
            elseif deltaX == 0 and deltaY ~= 0 then
                table_entry = table_entry + 2 ^ (getNS(deltaY))
                neighbour_count = neighbour_count + 1
            elseif deltaX ~= 0 and deltaY ~= 0 then
                if math.abs(deltaX) > math.abs(deltaY) then
                    table_entry = table_entry + 2 ^ (getEW(deltaX))
                elseif math.abs(deltaX) < math.abs(deltaY) then
                    table_entry = table_entry + 2 ^ (getNS(deltaY))
                end
                neighbour_count = neighbour_count + 1
            end
        end
    end
    if neighbour_count > 0 then
        if reverse_entity then
            table_entry = table_entry - get_direction(entity, reverse_entity)
        end
        place_clamped_pipe(entity, table_entry, player, lock_pipe, autoclamp)
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
    elseif deltaX ~= 0 and deltaY ~= 0 then
        return math.sqrt(((deltaX ^ 2) + (deltaY ^ 2)))
    end
end
--))

--[[local function count_fluid_boxes(subsequent_entities, entity)
    local fluid_box_counter = 0
    for _, subsequent_neighbour in pairs(subsequent_entities) do
        if subsequent_neighbour ~= entity then
            fluid_box_counter = fluid_box_counter + 1
        end
    end
    return fluid_box_counter
end]]
local function check_sub_neighbours(sub_neighbours, neighbour, entity)
    local fluid_box_counter = 0
    for _, subsequent_entities in pairs(sub_neighbours) do
        for _, subsequent_neighbour in pairs(subsequent_entities) do
            if subsequent_neighbour ~= entity then
                fluid_box_counter = fluid_box_counter + 1
            end
        end
        if fluid_box_counter > 1 then
            return neighbour
        end
    end
end

local function pipe_autoclamp_clamp(event, unclamp)
    local entity = event.created_entity
    local player, pdata = Player.get(event.player_index)

    local pipes_to_clamp = {}
    local clamp_self

    local current_fluid = get_pipe_info(entity).fluid_name
    local last_pipe_data = get_pipe_info(get_last_pipe(player, pdata))
    local last_pipe = last_pipe_data.entity

    for _, entities in pairs(entity.neighbours) do
        for _, neighbour in pairs(entities) do
            if neighbour.type == 'pipe' then
                local neighbour_fluid = get_pipe_info(neighbour).fluid_name
                if current_fluid then
                    --! Ensure fluids don't mix
                    if neighbour_fluid and (neighbour_fluid ~= current_fluid) then --? If the neighbour has a fluid and they don't match, we're clamping it. Period.
                        neighbour.surface.create_entity {
                            name = 'flying-text',
                            position = neighbour.position,
                            text = {'pipe-tools.mismatch'},
                            time_to_live = 120,
                            speed = 0,
                            color = red
                        }
                        pipes_to_clamp[#pipes_to_clamp + 1] = neighbour
                    elseif not unclamp and not pdata.disable_auto_clamp then --? This is not a logic duplicate of below. This branch is different and has a different purpose than above.
                        --! If the player wasn't unclamping, do further checks if auto clamp is on.
                        if last_pipe and neighbour ~= last_pipe then --? If there's a last pipe make sure it isnt the neighbour. If it's not clamp it. Allows parallel laying and T-ing into a pipeline.
                            pipes_to_clamp[#pipes_to_clamp + 1] = check_sub_neighbours(neighbour.neighbours, neighbour, entity)
                        elseif not last_pipe then --? Explicit check to make sure there isn't a last pipe. I don't want false to the above but then last pipe getting clamped anyways.
                            pipes_to_clamp[#pipes_to_clamp + 1] = check_sub_neighbours(neighbour.neighbours, neighbour, entity)
                        end
                    end
                elseif not unclamp and not pdata.disable_auto_clamp then --? If the current pipe doesn't have a fluid, make sure the player wasn't just unclamping, and make sure auto clamp is on.
                    --! <AUTO CLAMP MODE>
                    if last_pipe and neighbour ~= last_pipe and get_distance(entity, last_pipe) == 1 then --? This will see if last pipe exists, make sure that the neighbour isn't the last pipe, and if it isn't, see if it's within a tile (Tracking last pipes fluid)
                        if last_pipe_data.fluid_name and neighbour_fluid and (last_pipe_data.fluid_name ~= neighbour_fluid) then --? Within, if the last pipe has a fluid name see if the neighbour has a fluid. If so, do they match? If not clamp that neighbour. Allows parallel pipe laying of dissimilar fluids.
                            neighbour.surface.create_entity {
                                name = 'flying-text',
                                position = neighbour.position,
                                text = {'pipe-tools.mismatch'},
                                time_to_live = 120,
                                speed = 0,
                                color = red
                            }
                            pipes_to_clamp[#pipes_to_clamp + 1] = neighbour
                        else --? Clamp the neighbour if it's part of an existing pipeline
                            pipes_to_clamp[#pipes_to_clamp + 1] = check_sub_neighbours(neighbour.neighbours, neighbour, entity)
                        end
                    elseif not last_pipe or (last_pipe and get_distance(entity, last_pipe) ~= 1) then --? Catches all other cases
                        pipes_to_clamp[#pipes_to_clamp + 1] = check_sub_neighbours(neighbour.neighbours, neighbour, entity)
                    end
                end
            elseif not pdata.disable_auto_clamp and neighbour.type == 'storage-tank' then --? If it's not a pipe, we need to clamp our own pipe instead.
                local neighbour_fluid = get_pipe_info(neighbour).fluid_name --? NOTES: Try simple entity placement to prevent spam.
                if current_fluid then --?
                    if current_fluid ~= neighbour_fluid then --?
                        entity.surface.create_entity {
                            name = 'flying-text',
                            position = entity.position,
                            text = {'pipe-tools.mismatch'},
                            time_to_live = 120,
                            speed = 0,
                            color = red
                        }
                        clamp_self = neighbour
                    end
                elseif last_pipe and neighbour ~= last_pipe and get_distance(entity, last_pipe) == 1 then
                    if last_pipe_data.fluid_name and neighbour_fluid and (last_pipe_data.fluid_name ~= neighbour_fluid) then --? Last tracked fluid
                        entity.surface.create_entity {
                            name = 'flying-text',
                            position = entity.position,
                            text = {'pipe-tools.mismatch'},
                            time_to_live = 120,
                            speed = 0,
                            color = red
                        }
                        clamp_self = neighbour
                    end
                end
            end
        end
    end
    for _, entities in pairs(pipes_to_clamp) do
        clamp_pipe(entities, player, false, true, entity)
    end
    if clamp_self then
        clamp_pipe(entity, player, false, true, clamp_self)
    end
end

local function un_clamp_pipe(entity, player, area_unclamp)
    local pos = entity.position
    local filter_table = entity.fluidbox.get_filter(1)
    local event_data = {
        entity = entity,
        player_index = player.index
    }
    script.raise_event(defines.events.script_raised_destroy, event_data)
    local new =
        entity.surface.create_entity {
        name = entity.prototype.mineable_properties.products[1].name,
        position = pos,
        force = entity.force,
        fast_replace = true,
        spill = false
    }
    if not area_unclamp then
        new.surface.create_entity {
            name = 'flying-text',
            position = pos,
            text = {'pipe-tools.unclamped'},
            color = yellow
        }
    end
    new.last_user = player
    new.fluidbox.set_filter(1, filter_table)
    local event = {
        created_entity = new,
        player_index = player.index,
        clamped = false
    }
    script.raise_event(defines.events.script_raised_built, event)
    if entity then
        entity.destroy()
    end
    pipe_autoclamp_clamp(event, true)
end

local function toggle_pipe_clamp(event)
    local player, _ = Player.get(event.player_index)
    local selection = player.selected
    if selection and selection.type == 'pipe' and selection.force == player.force and not not_clampable_pipes[selection.name] then
        local clamped = string.find(selection.name, '%-clamped%-')
        if not clamped then
            clamp_pipe(selection, player, true)
        elseif clamped then
            un_clamp_pipe(selection, player)
        end
    end
end

local function toggle_area_clamp(event)
    if event.item == 'picker-pipe-clamper' then
        local clamp = event.name == defines.events.on_player_selected_area
        local player = game.players[event.player_index]
        for _, entity in pairs(event.entities) do
            if entity.valid and entity.type == 'pipe' and not not_clampable_pipes[entity.name] then --? Verify entity still exists. Un_clamp fires pipe_autoclamp_clamp which may replace an entity in the event.entities table
                local clamped = string.find(entity.name, '%-clamped%-')
                if clamp and not clamped then
                    clamp_pipe(entity, player)
                elseif not clamp and clamped then
                    un_clamp_pipe(entity, player, true)
                end
            end
        end
    end
end

local function on_built_entity(event)
    if event.created_entity and event.created_entity.type == 'pipe' and not not_clampable_pipes[event.created_entity.name] then
        local _, pdata = Player.get(event.player_index)
        local position_to_save = event.created_entity.position --? Store position ahead of time. Entity can be invalidated (replaced) during the following function before storing it's position.
        pipe_autoclamp_clamp(event, false)
        pdata.last_pipe_position = position_to_save
    end
end

local truthy = {['on'] = true, ['true'] = true}
local falsey = {['off'] = true, ['false'] = true}

local function toggle_auto_clamp(event)
    local player, pdata = Player.get(event.player_index)
    if truthy[event.parameter] then
        pdata.disable_auto_clamp = false
    elseif falsey[event.parameter] then
        pdata.disable_auto_clamp = true
    else
        pdata.disable_auto_clamp = not pdata.disable_auto_clamp
    end
    player.print({'pipe-tools.auto-clamp', pdata.disable_auto_clamp and {'pipe-tools.off'} or {'pipe-tools.on'}})
    return pdata.disable_auto_clamp
end

if settings.startup['picker-tool-pipe-clamps'].value then
    Event.register('picker-toggle-pipe-clamp', toggle_pipe_clamp)
    Event.register({defines.events.on_player_selected_area, defines.events.on_player_alt_selected_area}, toggle_area_clamp)
    Event.register(defines.events.on_built_entity, on_built_entity)

    Event.register('picker-auto-clamp-toggle', toggle_auto_clamp)
    commands.add_command('autoclamp', {'autoclamp-commands.toggle-autoclamp'}, toggle_auto_clamp)
end
remote.add_interface(script.mod_name, require('lib/interface'))
