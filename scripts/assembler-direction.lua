-------------------------------------------------------------------------------
--[Copy pipe direction]--
-------------------------------------------------------------------------------
--Modified from "Copy Assembler Pipe Direction", by "IronCartographer",
--https://mods.factorio.com/mods/IronCartographer/CopyAssemblerPipeDirection

local Event = require('__stdlib__/stdlib/event/event')
local group = {
    ['assembling-machine'] = true
}

---@todo Is this even needed anymore?
---@param event EventData.on_entity_settings_pasted
local function on_entity_settings_pasted(event)
    --Copy assembler pipe direction if entity is square and has fluidboxes
    local player = game.get_player(event.player_index)
    if not player.mod_settings['picker-assembler-direction'].value then return end

    local src, dst = event.source, event.destination
    if not (src and src.supports_direction and dst and dst.supports_direction) then return end

    local src_fluid, dst_fluid = src.fluidbox, dst.fluidbox
    if not (src_fluid and #src_fluid > 0 and dst_fluid and #dst_fluid > 0) then return end

    local src_proto, dst_proto = src.prototype, dst.prototype
    if not (group[src_proto.fast_replaceable_group] and group[dst_proto.fast_replaceable_group]) then return end

    local src_box, dst_box = src_proto.collision_box, dst_proto.collision_box
    ---@todo Need prototype.tile_width and prototoype.tile_height
    if not (src_box and dst_box and src_box.left_top.x == dst_box.left_top.x and dst_box.right_bottom.y == src_box.right_bottom) then return end

    dst.direction = src.direction
end
Event.register(defines.events.on_entity_settings_pasted, on_entity_settings_pasted)
