--[[
    A basic interface script, with generic functions
    usage:
    local interface = require(__stdlib__/stdlib/scripts/interface)
    interface.myfunc = function() end
    remote.add_interface(script.mod_name, interface)
    interface.myfunc2 = function() end -- Can even add new functions afterwards!
]]
local interface = {}
local table = require('lib/table')

local Player = require('lib/player')
local Force = require('lib/player')

local serp_settings = {comment = false, nocode = true}

interface['write_global'] = function()
    --game.remove_path(script.mod_name)
    game.write_file(script.mod_name .. '/global.lua', serpent.block(global, serp_settings), false)
    game.write_file(script.mod_name .. '/global-inspect.lua', inspect(global), false)
    if remote.interfaces[script.mod_name] then
        game.write_file(script.mod_name .. '/interfaces.lua', serpent.block(table.keys(remote.interfaces[script.mod_name], true, true), serp_settings))
    end
    Player.dump_data()
    Force.dump_data()
end


return interface
