local north = {position = {0, -1}}
local south = {position = {0, 1}}
local west = {position = {-1, 0}}
local east = {position = {1, 0}}

local not_clampable = {
    ['4-to-4-pipe'] = true,
    ['factory-fluid-dummy-connector'] = true,
    ['factory-fluid-dummy-connector-south'] = true,
}
local clamped_layer = {
    straight_vertical = {
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-straight-vertical.png'
    },
    straight_horizontal = {
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-straight-horizontal.png'
    },
    corner_up_right = {
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-corner-up-right.png'
    },
    corner_up_left = {
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-corner-up-left.png'
    },
    corner_down_right = {
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-corner-down-right.png'
    },
    corner_down_left = {
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-corner-down-left.png'
    },
    t_up = {
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-t-up.png'
    },
    t_down = {
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-t-down.png'
    },
    t_right = {
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-t-right.png'
    },
    t_left = {
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-t-left.png'
    },
    ending_up = {
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-ending-up.png'
    },
    ending_down = {
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-ending-down.png'
    },
    ending_right = {
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-ending-right.png'
    },
    ending_left = {
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-ending-left.png'
    },
    cross = {
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-cross.png'
    }
}

local pipe_make_table = {
    ['single'] = {
        locale = '[Single]',
        positions = {north},
        pictures = {
            up = 'ending_up',
            left = 'ending_left',
            down = 'ending_down',
            right = 'ending_right'
        }
    },
    ['l'] = {
        locale = '[Elbow]',
        positions = {north,west},
        pictures = {
            up = 'corner_up_left',
            right = 'corner_up_right',
            down = 'corner_down_right',
            left = 'corner_down_left'
        }
    },
    ['i'] = {
        locale = '[Straight]',
        positions = {north,south},
        pictures = {
            up = 'straight_vertical',
            right = 'straight_horizontal',
            down = 'straight_vertical',
            left = 'straight_horizontal'
        }
    },
    ['t'] = {
        locale = '[T junction]',
        positions = {north,east,west},
        pictures = {
            up = 't_up',
            right = 't_right',
            down = 't_down',
            left = 't_left'
        }
    },
    ['x'] = {
        locale = '[Cross junction]',
        positions = {north,east,south,west},
        pictures = {
            up = 'cross',
            right = 'cross',
            down = 'cross',
            left = 'cross'
        }
    }
}

local file_path = "__PickerPipeTools__/graphics/entity/pipe/hr-pipe-"

local function build_picture_table(current_picture_table, current_name)
    return {
        up = {
            layers = {
                current_picture_table[pipe_make_table[current_name].pictures.up],
                {
                    filename = clamped_layer[pipe_make_table[current_name].pictures.up].hr_image_path,
                    priority = "high",
                    width = 128,
                    height = 128,
                    scale = 0.5
                },
            }
        },
        down = {
            layers = {
                current_picture_table[pipe_make_table[current_name].pictures.down],
                {
                    filename = clamped_layer[pipe_make_table[current_name].pictures.down].hr_image_path,
                    priority = "high",
                    width = 128,
                    height = 128,
                    scale = 0.5
                },
            }
        },
        left = {
            layers = {
                current_picture_table[pipe_make_table[current_name].pictures.left],
                {
                    filename = clamped_layer[pipe_make_table[current_name].pictures.left].hr_image_path,
                    priority = "high",
                    width = 128,
                    height = 128,
                    scale = 0.5
                },
            }
        },
        right = {
            layers = {
                current_picture_table[pipe_make_table[current_name].pictures.right],
                {
                    filename = clamped_layer[pipe_make_table[current_name].pictures.right].hr_image_path,
                    priority = "high",
                    width = 128,
                    height = 128,
                    scale = 0.5
                },
            }
        },
    }
end

if settings.startup['picker-tool-pipe-clamps'].value then
    local pipeEntities = {}
    for i, pipe in pairs(data.raw['pipe']) do
        for names, pipe_data in pairs(pipe_make_table) do
            if not pipe.clamped 
            --and not string.find(pipe.name, 'dummy%-') 
            and not string.find(pipe.name, '%[') 
            and not string.find(pipe.name, 'bpproxy') 
            and not not_clampable[pipe.name] then
                local current_entity = util.table.deepcopy(pipe)
                current_entity.type = 'pipe-to-ground'
                current_entity.name = pipe.name .. '-clamped-' .. names
                current_entity.clamped = true
                current_entity.localised_name = {'pipe-tools.clamped-name', pipe.name, pipe_data.locale}
                current_entity.placeable_by = {item = pipe.minable and pipe.minable.result or pipe.name, count = pipe.minable and pipe.minable.count or 1}
                current_entity.underground_sprite = util.table.deepcopy(data.raw['pipe-to-ground']['pipe-to-ground'].underground_sprite)
                current_entity.icons = {
                    {
                        icon = current_entity.icon or data.raw['pipe']['pipe'].icon,
                        icon_size = 32
                    },
                    {
                        icon = '__PickerPipeTools__/graphics/icons/lock.png',
                        icon_size = 32
                    }
                }
                current_entity.flags = {'placeable-neutral', 'player-creation', 'fast-replaceable-no-build-while-moving'}
                current_entity.fluid_box.pipe_connections = pipe_data.positions
                current_entity.fluid_box.pipe_covers = _G.pipecoverspictures()
                current_entity.pictures = build_picture_table(current_entity.pictures, names)

                pipeEntities[#pipeEntities + 1] = current_entity
            end
        end
    end

    data:extend(pipeEntities)

    data:extend {
        {
            type = 'selection-tool',
            name = 'picker-pipe-clamper',
            icon = '__PickerPipeTools__/graphics/icons/hr-lock.png',
            icon_size = 64,
            flags = {'hidden'},
            subgroup = 'tool',
            order = 'c[selection-tool]-a[pipe-cleaner]',
            stack_size = 1,
            stackable = false,
            selection_color = {r = 1, g = 0, b = 0},
            alt_selection_color = {r = 0, g = 1, b = 0},
            selection_mode = {'buildable-type', 'items-to-place'},
            alt_selection_mode = {'buildable-type', 'items-to-place'},
            selection_cursor_box_type = 'copy',
            alt_selection_cursor_box_type = 'copy',
            always_include_tiles = false,
            show_in_library = true
        }
    }
end





local nameTable = {
    --[[["none"] = {
        locale = "[none]",
        positions = {},
    },]]--
    ['E'] = {
        locale = '[East]',
        positions = {east}
    },
    ['W'] = {
        locale = '[West]',
        positions = {west}
    },
    ['N'] = {
        locale = '[North]',
        positions = {north}
    },
    ['S'] = {
        locale = '[South]',
        positions = {south}
    },
    ['EW'] = {
        locale = '[East, West]',
        positions = {east, west},
        layers_to_keep = {
            straight_horizontal_window = {
                keep = true,
                hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-straight-horizontal-window.png'
            },
            straight_horizontal = {
                keep = true,
                hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-straight-horizontal.png'
            }
        }
    },
    ['NW'] = {
        locale = '[North, West]',
        positions = {north, west},
        layers_to_keep = {
            corner_up_left = {
                keep = true,
                hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-corner-up-left.png'
            }
        }
    },
    ['NE'] = {
        locale = '[North, East]',
        positions = {north, east},
        layers_to_keep = {
            corner_up_right = {
                keep = true,
                hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-corner-up-right.png'
            }
        }
    },
    ['NEW'] = {
        locale = '[North, East, West]',
        positions = {north, east, west},
        layers_to_keep = {
            t_up = {
                keep = true,
                hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-t-up.png'
            }
        }
    },
    ['SW'] = {
        locale = '[South, West]',
        positions = {south, west},
        layers_to_keep = {
            corner_up_left = {
                keep = true,
                hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-corner-up-left.png'
            }
        }
    },
    ['SE'] = {
        locale = '[South, East]',
        positions = {south, east},
        layers_to_keep = {
            corner_down_right = {
                keep = true,
                hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-corner-down-right.png'
            }
        }
    },
    ['SEW'] = {
        locale = '[South, East, West]',
        positions = {south, east, west},
        layers_to_keep = {
            t_down = {
                keep = true,
                hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-t-down.png'
            }
        }
    },
    ['NS'] = {
        locale = '[North, South]',
        positions = {north, south},
        layers_to_keep = {
            straight_vertical_window = {
                keep = true,
                hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-straight-vertical-window.png'
            },
            straight_vertical = {
                keep = true,
                hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-straight-vertical.png'
            }
        }
    },
    ['NSW'] = {
        locale = '[North, South, West]',
        positions = {north, south, west},
        layers_to_keep = {
            t_left = {
                keep = true,
                hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-t-left.png'
            }
        }
    },
    ['NSE'] = {
        locale = '[North, South, East]',
        positions = {north, south, east},
        layers_to_keep = {
            t_right = {
                keep = true,
                hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-t-right.png'
            }
        }
    },
    ['NSEW'] = {
        locale = '[North, South, East, West]',
        positions = {north, south, east, west},
        layers_to_keep = {
            t_right = {
                keep = true,
                hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-cross.png'
            }
        }
    }
}

local clamped_layer = {
    straight_vertical_single = {
        add_layer = true,
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-straight-vertical-single.png'
    },
    straight_vertical = {
        add_layer = true,
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-straight-vertical.png'
    },
    straight_vertical_window = {
        add_layer = true,
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-straight-vertical-window.png'
    },
    straight_horizontal_window = {
        add_layer = true,
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-straight-horizontal-window.png'
    },
    straight_horizontal = {
        add_layer = true,
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-straight-horizontal.png'
    },
    corner_up_right = {
        add_layer = true,
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-corner-up-right.png'
    },
    corner_up_left = {
        add_layer = true,
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-corner-up-left.png'
    },
    corner_down_right = {
        add_layer = true,
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-corner-down-right.png'
    },
    corner_down_left = {
        add_layer = true,
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-corner-down-left.png'
    },
    t_up = {
        add_layer = true,
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-t-up.png'
    },
    t_down = {
        add_layer = true,
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-t-down.png'
    },
    t_right = {
        add_layer = true,
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-t-right.png'
    },
    t_left = {
        add_layer = true,
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-t-left.png'
    },
    ending_up = {
        add_layer = true,
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-ending-up.png'
    },
    ending_down = {
        add_layer = true,
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-ending-down.png'
    },
    ending_right = {
        add_layer = true,
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-ending-right.png'
    },
    ending_left = {
        add_layer = true,
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-ending-left.png'
    },
    cross = {
        add_layer = true,
        hr_image_path = '__PickerPipeTools__/graphics/entity/pipe/hr-pipe-cross.png'
    }
}
local dontChange = {
    horizontal_window_background = true,
    vertical_window_background = true,
    gas_flow = true,
    fluid_background = true,
    window_background = true,
    flow_sprite = true
}

local function _create_picture_table_(data, name)
    for pictureName, _ in pairs(data) do
        if not dontChange[pictureName] then
            if clamped_layer[pictureName] and clamped_layer[pictureName].add_layer and nameTable[name].layers_to_keep[pictureName] then
                local currentLayerData = data[pictureName]
                data[pictureName] = {
                    layers = {
                        currentLayerData,
                        {
                            filename = clamped_layer[pictureName].hr_image_path,
                            --"__PickerPipeTools__/graphics/icons/lock.png",
                            priority = 'extra-high',
                            width = 128,
                            height = 128,
                            --scale = 0.8,
                            scale = 0.25,
                            --shift = util.by_pixel(0, -5),
                            hr_version = {
                                filename = clamped_layer[pictureName].hr_image_path,
                                priority = 'extra-high',
                                width = 128,
                                height = 128,
                                scale = 0.5
                                --shift = util.by_pixel(0, -5)
                            }
                        }
                    }
                }
            elseif clamped_layer[pictureName] and clamped_layer[pictureName].add_layer and not nameTable[name].layers_to_keep[pictureName] then
                local layer_image_to_keep = {}
                local layer_to_keep = {}
                for layerName, layers in pairs(nameTable[name].layers_to_keep) do
                    layer_to_keep = layerName
                    layer_image_to_keep = layers.hr_image_path
                end
                local currentLayerData = data[layer_to_keep]
                data[pictureName] = {
                    layers = {
                        currentLayerData,
                        {
                            filename = clamped_layer[pictureName].hr_image_path,
                            --"__PickerPipeTools__/graphics/icons/lock.png",
                            priority = 'extra-high',
                            width = 128,
                            height = 128,
                            --scale = 0.8,
                            scale = 0.25,
                            --shift = util.by_pixel(0, -5),
                            hr_version = {
                                filename = layer_image_to_keep,
                                priority = 'extra-high',
                                width = 128,
                                height = 128,
                                scale = 0.5
                                --shift = util.by_pixel(0, -5)
                            }
                        }
                    }
                }
            end
        end
    end
    return data
end

if settings.startup['picker-tool-pipe-clamps'].value then
    local pipeEntities = {}
    for i, pipe in pairs(data.raw['pipe']) do
        for name, pipeData in pairs(nameTable) do
            if not pipe.clamped and not string.find(pipe.name, 'dummy%-') and not string.find(pipe.name, '%[') and not string.find(pipe.name, 'bpproxy') then
                local current_entity = util.table.deepcopy(pipe)
                current_entity.name = pipe.name .. '-clamped-' .. name
                current_entity.clamped = true
                current_entity.localised_name = {'pipe-tools.clamped-name', pipe.name, pipeData.locale}
                current_entity.placeable_by = {item = pipe.minable and pipe.minable.result or pipe.name, count = pipe.minable and pipe.minable.count or 1}
                current_entity.icons = {
                    {
                        icon = current_entity.icon or data.raw['pipe']['pipe'].icon,
                        icon_size = 32
                    },
                    {
                        icon = '__PickerPipeTools__/graphics/icons/lock.png',
                        icon_size = 32
                    }
                }
                current_entity.flags = {'placeable-neutral', 'player-creation', 'fast-replaceable-no-build-while-moving'}
                current_entity.fluid_box.pipe_connections = pipeData.positions
                current_entity.fluid_box.pipe_covers = _G.pipecoverspictures()
                --local picture_table = util.table.deepcopy(current_entity.pictures)
                --current_entity.pictures = create_picture_table(picture_table, name)
                for pictureName, _ in pairs(current_entity.pictures) do
                    if not dontChange[pictureName] then
                        if clamped_layer[pictureName] and clamped_layer[pictureName].add_layer then
                            local currentLayerData = current_entity.pictures[pictureName]
                            current_entity.pictures[pictureName] = {
                                layers = {
                                    currentLayerData,
                                    {
                                        filename = clamped_layer[pictureName].hr_image_path,
                                        --"__PickerPipeTools__/graphics/icons/lock.png",
                                        priority = 'extra-high',
                                        width = 128,
                                        height = 128,
                                        --scale = 0.8,
                                        scale = 0.5,
                                        --shift = util.by_pixel(0, -5),
                                        hr_version = {
                                            filename = clamped_layer[pictureName].hr_image_path,
                                            priority = 'extra-high',
                                            width = 128,
                                            height = 128,
                                            scale = 0.5
                                            --shift = util.by_pixel(0, -5)
                                        }
                                    }
                                }
                            }
                        end
                    end
                end
                pipeEntities[#pipeEntities + 1] = current_entity
            end
        end
    end

    data:extend(pipeEntities)

    data:extend {
        {
            type = 'selection-tool',
            name = 'picker-pipe-clamper',
            icon = '__PickerPipeTools__/graphics/icons/hr-lock.png',
            icon_size = 64,
            flags = {'hidden'},
            subgroup = 'tool',
            order = 'c[selection-tool]-a[pipe-cleaner]',
            stack_size = 1,
            stackable = false,
            selection_color = {r = 1, g = 0, b = 0},
            alt_selection_color = {r = 0, g = 1, b = 0},
            selection_mode = {'buildable-type', 'items-to-place'},
            alt_selection_mode = {'buildable-type', 'items-to-place'},
            selection_cursor_box_type = 'copy',
            alt_selection_cursor_box_type = 'copy',
            always_include_tiles = false,
            show_in_library = true
        }
    }
end