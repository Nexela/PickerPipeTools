local Data = require('__stdlib__/stdlib/data/data')

local table = require('__stdlib__/stdlib/utils/table')

local north = {position = {0, -1}}
local south = {position = {0, 1}}
local west = {position = {-1, 0}}
local east = {position = {1, 0}}

local nameTable = {
    ['EW'] = {
        locale = '[East, West]',
        positions = {east, west}
    },
    ['NW'] = {
        locale = '[North, West]',
        positions = {north, west}
    },
    ['NE'] = {
        locale = '[North, East]',
        positions = {north, east}
    },
    ['NEW'] = {
        locale = '[North, East, West]',
        positions = {north, east, west}
    },
    ['SW'] = {
        locale = '[South, West]',
        positions = {south, west}
    },
    ['SE'] = {
        locale = '[South, East]',
        positions = {south, east}
    },
    ['SEW'] = {
        locale = '[South, East, West]',
        positions = {south, east, west}
    },
    ['NS'] = {
        locale = '[North, South]',
        positions = {north, south}
    },
    ['NSW'] = {
        locale = '[North, South, West]',
        positions = {north, south, west}
    },
    ['NSE'] = {
        locale = '[North, South, East]',
        positions = {north, south, east}
    }
}

local clamped_layer = {
    --[[straight_vertical_single = {
        add_layer = true,
        hr_image_path = "__PickerPipeTools__/graphics/pipe/hr-pipe-straight-vertical-single.png"
    },]]--
    straight_vertical = {
        add_layer = true,
        hr_image_path = "__PickerPipeTools__/graphics/pipe/hr-pipe-straight-vertical.png"
    },
    straight_vertical_window = {
        add_layer = true,
        hr_image_path = "__PickerPipeTools__/graphics/pipe/hr-pipe-straight-vertical-window.png"
    },
    straight_horizontal_window = {
        add_layer = true,
        hr_image_path = "__PickerPipeTools__/graphics/pipe/hr-pipe-straight-horizontal-window.png"
    },
    straight_horizontal = {
        add_layer = true,
        hr_image_path = "__PickerPipeTools__/graphics/pipe/hr-pipe-straight-horizontal.png"
    },
    corner_up_right = {
        add_layer = true,
        hr_image_path = "__PickerPipeTools__/graphics/pipe/hr-pipe-corner-up-right.png"
    },
    corner_up_left = {
        add_layer = true,
        hr_image_path = "__PickerPipeTools__/graphics/pipe/hr-pipe-corner-up-left.png"
    },
    corner_down_right = {
        add_layer = true,
        hr_image_path = "__PickerPipeTools__/graphics/pipe/hr-pipe-corner-down-right.png"
    },
    corner_down_left = {
        add_layer = true,
        hr_image_path = "__PickerPipeTools__/graphics/pipe/hr-pipe-corner-down-left.png"
    },
    t_up = {
        add_layer = true,
        hr_image_path = "__PickerPipeTools__/graphics/pipe/hr-pipe-t-up.png"
    },
    t_down = {
        add_layer = true,
        hr_image_path = "__PickerPipeTools__/graphics/pipe/hr-pipe-t-down.png"
    },
    t_right = {
        add_layer = true,
        hr_image_path = "__PickerPipeTools__/graphics/pipe/hr-pipe-t-right.png"
    },
    t_left = {
        add_layer = true,
        hr_image_path = "__PickerPipeTools__/graphics/pipe/hr-pipe-t-left.png"
    },
    ending_up = {
        add_layer = true,
        hr_image_path = "__PickerPipeTools__/graphics/pipe/hr-pipe-ending-up.png"
    },
    ending_down = {
        add_layer = true,
        hr_image_path = "__PickerPipeTools__/graphics/pipe/hr-pipe-ending-down.png"
    },
    ending_right = {
        add_layer = true,
        hr_image_path = "__PickerPipeTools__/graphics/pipe/hr-pipe-ending-right.png"
    },
    ending_left = {
        add_layer = true,
        hr_image_path = "__PickerPipeTools__/graphics/pipe/hr-pipe-ending-left.png"
    },
}

local ignore_pictures = {
    gas_flow = true,
    fluid_background = true,
    window_background = true,
    flow_sprite = true
}

local pipe_entities = {}
for i, pipe in pairs(data.raw['pipe']) do
    -- TODO Data.pairs()
    for name, pipe_data in pairs(nameTable) do
        if not pipe.clamped and not string.find(pipe.name, 'dummy%-') then
            local new_entity = table.deep_copy(pipe)

            new_entity.name = pipe.name .. '-clamped-' .. name
            new_entity.clamped = true
            new_entity.localised_name = {'pipe-tools.clamped-name', pipe.name, pipe_data.locale}
            new_entity.placeable_by = {item = pipe.name, count = pipe.minable and pipe.minable.count or 1}
            -- TODO get potential icon from icons[1]
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

            for pictureName, _ in pairs(new_entity.pictures) do
                if not ignore_pictures[pictureName] then
                    if clamped_layer[pictureName] and clamped_layer[pictureName].add_layer then
                        local currentLayerData = new_entity.pictures[pictureName]
                        new_entity.pictures[pictureName] = {
                            layers = {
                                currentLayerData,
                                {
                                    filename = "__PickerPipeTools__/graphics/icons/lock.png",
                                    priority = "extra-high",
                                    width = 32,
                                    height = 32,
                                    scale = 0.8,
                                    shift = util.by_pixel(0, -5),
                                    hr_version = {
                                        filename = clamped_layer[pictureName].hr_image_path,
                                        priority = "extra-high",
                                        width = 128,
                                        height = 128,
                                        scale = 0.5,
                                    }
                                }
                            }
                        }
                    end
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