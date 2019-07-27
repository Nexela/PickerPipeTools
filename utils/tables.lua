local Event = require('__stdlib__/stdlib/event/event')
local Position = require('__stdlib__/stdlib/area/position')
--local Position = require('__stdlib__/stdlib/area/position')
local tables = {}

tables.tick_options = {
    skip_valid = true,
    protected_mode = false
}

tables.protected = {
    protected_mode = Event.options.protected_mode,
    skip_valid = true
}
tables.empty = {}

tables.draw_dashes_names = {
    ['underground-mini-pump'] = true,
    ['underground-mini-pump-t1'] = true,
    ['underground-mini-pump-t2'] = true,
    ['underground-mini-pump-t3'] = true,
    ['4-to-4-pipe'] = true
}

do
    local north = {
        left = Position(-0.4, -0.75),
        right = Position(0.4, -0.75),
        rev_left = Position(-0.4, 0.75),
        rev_right = Position(0.4, 0.75)
    }
    local east = {
        left = -north.right:swap(),
        right = -north.left:swap(),
        rev_left = -north.rev_right:swap(),
        rev_right = -north.rev_left:swap()
    }
    local south = {
        left = -north.left,
        right = -north.right,
        rev_left = -north.rev_left,
        rev_right = -north.rev_right
    }
    local west = {
        left = -east.left,
        right = -east.right,
        rev_left = -east.rev_left,
        rev_right = -east.rev_right
    }
    tables.ug_offsets = {
        [defines.direction.north] = north,
        [defines.direction.east] = east,
        [defines.direction.south] = south,
        [defines.direction.west] = west
    }
end

tables.bitwise_marker_entry = {
    [0x00] = 1,
    [0x01] = 2,
    [0x04] = 3,
    [0x05] = 4,
    [0x10] = 5,
    [0x11] = 6,
    [0x14] = 7,
    [0x15] = 8,
    [0x40] = 9,
    [0x41] = 10,
    [0x44] = 11,
    [0x45] = 12,
    [0x50] = 13,
    [0x51] = 14,
    [0x54] = 15,
    [0x55] = 16
}

tables.allowed_types = {
    ['pipe'] = true,
    ['pipe-to-ground'] = true,
    ['pump'] = true
}

tables.not_allowed_names = {
    ['factory-fluid-dummy-connector'] = true,
    ['factory-fluid-dummy-connector-south'] = true,
    ['offshore-pump-output'] = true
}

return tables
