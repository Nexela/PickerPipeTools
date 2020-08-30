-------------------------------------------------------------------------------
--[[Pipe Cleaner]] --
-------------------------------------------------------------------------------
--Loosley based on pipe manager by KeyboardHack
local Event = require('__stdlib__/stdlib/event/event')
local table = require('__stdlib__/stdlib/utils/table')

--Start at a drain and clear fluidboxes out that match. find drain connections not cleaned and repeat
local function call_a_plumber(event)
    local plumber = game.players[event.player_index]
    if not (plumber.admin or not settings.global['picker-tool-admin-only'].value) then
        return
    end

    local toilet = plumber.selected
    local ptrap = toilet and toilet.fluidbox
    if ptrap then
        for i = 1, #ptrap do
            ptrap.flush(i)
        end
        ptrap.owner.last_user = plumber
    end
end
Event.register('picker-pipe-cleaner', call_a_plumber)

--API request flush_filters
local function remove_graffiti(event)
    local plumber = game.players[event.player_index]
    if plumber.admin or not settings.global['picker-tool-admin-only'].value then
        local toilet = plumber.selected
        if toilet then
            local frame = plumber.gui.center.picker_pipe_filter

            if frame then
                frame.destroy()
            end

            local ptrap = toilet.fluidbox
            local toilets = {}
            local rootered = {}

            local function rooter_it(v)
                if not rootered[v.owner.unit_number] then
                    toilets[v.owner.unit_number] = v
                end
            end

            toilets[toilet.unit_number] = ptrap

            repeat
                local index, drain = next(toilets)
                if index then
                    rootered[index] = drain
                    for i = 1, #drain do
                        drain.set_filter(i, nil)
                        table.each(drain.get_connections(i), rooter_it)
                    end

                    toilets[index] = nil
                    drain.owner.last_user = plumber
                end
            until not index
            plumber.print({'pipe-cleaner.remove-all-filters'})
        end
    else
        plumber.print({'picker.must-be-admin'})
    end
end
Event.register('picker-filter-cleaner', remove_graffiti)
