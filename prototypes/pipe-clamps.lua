local Data = require('__stdlib__/stdlib/data/data')

local table = require('__stdlib__/stdlib/utils/table')

local north = {position = {0, -1}}
local south = {position = {0, 1}}
local west = {position = {-1, 0}}
local east = {position = {1, 0}}

local nameTable = {
    ['ew'] = {
        locale = '[East, West]',
        positions = {east, west}
    },
    ['nw'] = {
        locale = '[North, West]',
        positions = {north, west}
    },
    ['ne'] = {
        locale = '[North, East]',
        positions = {north, east}
    },
    ['new'] = {
        locale = '[North, East, West]',
        positions = {north, east, west}
    },
    ['sw'] = {
        locale = '[South, West]',
        positions = {south, west}
    },
    ['se'] = {
        locale = '[South, East]',
        positions = {south, east}
    },
    ['sew'] = {
        locale = '[South, East, West]',
        positions = {south, east, west}
    },
    ['ns'] = {
        locale = '[North, South]',
        positions = {north, south}
    },
    ['nsw'] = {
        locale = '[North, South, West]',
        positions = {north, south, west}
    },
    ['nse'] = {
        locale = '[North, South, East]',
        positions = {north, south, east}
    }
}

local ignore_pictures = {
    gas_flow = true,
    fluid_background = true,
    window_background = true,
    flow_sprite = true
}

local pipe_entities = {}
for i, pipe in pairs(data.raw['pipe']) do
    for name, pipe_data in pairs(nameTable) do
        if not pipe.clamped and not string.find(pipe.name, 'dummy%-') then
            local new_entity = table.deep_copy(pipe)

            new_entity.name = pipe.name .. '-clamped-' .. name
            new_entity.clamped = true
            new_entity.localised_name = {'pipe-tools.clamped-name', pipe.name, pipe_data.locale}
            new_entity.placeable_by = {item = pipe.name, count = pipe.minable and pipe.minable.count or 1}
            new_entity.icons = {
                {
                    icon = new_entity.icon or data.raw['pipe']['pipe'].icon,
                    icon_size = 32
                },
                {
                    icon = '__PickerPipeTools__/graphics/icons/lock.png',
                    icon_size = 32
                }
            }
            new_entity.flags = {'placeable-neutral', 'player-creation', 'fast-replaceable-no-build-while-moving'}
            new_entity.fluid_box.pipe_connections = table.deep_copy(pipe_data.positions)

            for picture_name, _ in pairs(new_entity.pictures) do
                if not ignore_pictures[picture_name] then
                    local current_layer = new_entity.pictures[picture_name]
                    new_entity.pictures[picture_name] = {
                        layers = {
                            current_layer,
                            {
                                filename = '__PickerPipeTools__/graphics/icons/lock.png',
                                priority = 'extra-high',
                                width = 32,
                                height = 32,
                                scale = 0.8,
                                shift = util.by_pixel(0, -5),
                                hr_version = {
                                    filename = '__PickerPipeTools__/graphics/icons/hr-lock.png',
                                    priority = 'extra-high',
                                    width = 64,
                                    height = 64,
                                    scale = 0.4,
                                    shift = util.by_pixel(0, -5)
                                }
                            }
                        }
                    }
                end
            end
            pipe_entities[#pipe_entities + 1] = new_entity
        end
    end
end
data:extend(pipe_entities)

Data {
    type = 'selection-tool',
    name = 'picker-pipe-clamper',
    icon = '__PickerPipeTools__/graphics/icons/hr-lock.png',
    icon_size = 64,
    flags = {'hidden', 'only-in-cursor'},
    subgroup = 'tool',
    order = 'c[selection-tool]-a[pipe-cleaner]',
    stack_size = 1,
    stackable = false,
    selection_color = {r = 1, g = 0, b = 0},
    alt_selection_color = {r = 0, g = 1, b = 0},
    selection_mode = {'same-force', 'buildable-type', 'items-to-place'},
    alt_selection_mode = {'same-force', 'buildable-type', 'items-to-place'},
    selection_cursor_box_type = 'copy',
    alt_selection_cursor_box_type = 'copy',
    always_include_tiles = false,
    show_in_library = true
}