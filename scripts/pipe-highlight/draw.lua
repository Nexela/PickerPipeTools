local draw_sprite = rendering.draw_sprite
local draw_line = rendering.draw_line
local destroy = rendering.destroy
local t = require('utils/tables')
local utils = require('scripts/utils')
local draw = {}

draw.green = {0,1,0,1}
draw.red = {1,0,0,1}
draw.yellow = {1,1,0,1}
function draw.destroy_markers(markers)
    for _, mark in pairs(markers or t.empty) do
        destroy(mark)
    end
end

function draw.update_markers(markers, color)
    for _, mark in pairs(markers) do
        set_color(mark, color)
    end
end

function draw.draw_dot(entity_data, color, player_index)
    local player, pdata = Player.get(player_index)

end

function draw.draw_pump_mark(entity_data, color, player_index)
    local player, pdata = Player.get(player_index)

end

function draw.draw_ug_segment(current_entity, neighbour_entity, color, player_index)
    local ug_marker = t[utils.get_direction(current_entity[1], neighbour_entity[1])]
    local surface = current_entity[5].surface
    local marker_one =
        draw_line {
        color = color,
        width = 3,
        gap_length = 0.5,
        dash_length = 0.5,
        from = current_entity[5],
        from_offset = ug_marker.left,
        to = neighbour_entity[5],
        to_offset = ug_marker.rev_left,
        surface = surface,
        players = {player_index}
    }
    local marker_two =
        draw_line {
        color = color,
        width = 3,
        gap_length = 0.5,
        dash_length = 0.5,
        from = current_entity[5],
        from_offset = ug_marker.right,
        to = neighbour_entity[5],
        to_offset = ug_marker.rev_right,
        surface = surface,
        players = {player_index}
    }
    return marker_one,marker_two
end
