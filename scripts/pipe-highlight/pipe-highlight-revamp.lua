-------------------------------------------------------------------------------
--[[Pipe Highlighter]] --
-------------------------------------------------------------------------------
-- Concept designed and code written by TheStaplergun (staplergun on mod portal)
-- STDLib and code reviews provided by Nexela

local Player = require('__stdlib__/stdlib/event/player')
local Event = require('__stdlib__/stdlib/event/event')
local Position = require('__stdlib__/stdlib/area/position')
local Direction = require('__stdlib__/stdlib/area/direction')
local utils = require('scripts/utils')
local t = require('utils/tables')
local d = require('draw')
local pipe_connections = {}

local function load_pipe_connections()
    if remote.interfaces['underground-pipe-pack'] then
        pipe_connections = remote.call('underground-pipe-pack', 'get_pipe_table')
    end
end
Event.register({Event.core_events.init, Event.core_events.load}, load_pipe_connections)

local funcion read_pipeline(starter_entity, player_index)
    local player, pdata = Player.get(player_index)
    local read_entity_data = {}
    local read_neighbour_data = {}
    local all_entities_marked ={}
    local all_markers = {}
    local orphans = {}

end
