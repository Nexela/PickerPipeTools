local merge = _G.util.merge
local base_entity = {
    type = "corpse",
    name = 'fillerstuff',
    flags = {"placeable-neutral", "not-on-map"},
    subgroup="remnants",
    order="d[remnants]-c[wall]",
    --type = 'simple-entity',
    icon = '__PickerPipeTools__/graphics/entity/markers/32x32highlighter.png',
    icon_size = 32,
    time_before_removed = 2000000000,
    collision_box = {{0, 0}, {0, 0}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    selectable_in_game = false,
    final_render_layer = 'selection-box',
    animation = {
        width = 64,
        height = 64,
        frame_count = 1,
        direction_count = 1,
        --scale = 0.5,
        --shift = {-0.5, -0.5},
        filename = '__PickerPipeTools__/graphics/entity/markers/32x32highlighter.png'
    }
}

local dot_table = {
    'picker-pipe-dot',
    'picker-pipe-dot-good',
    'picker-pipe-dot-bad'
}

local dot_image_table = {
    'pipe-marker-dot',
    'pipe-marker-dot-good',
    'pipe-marker-dot-bad'
}

local directional_table = {
    '',
    '-n',
    '-e',
    '-ne',
    '-s',
    '-ns',
    '-se',
    '-nse',
    '-w',
    '-nw',
    '-ew',
    '-new',
    '-sw',
    '-nsw',
    '-sew',
    '-nsew'
}
local new_dots = {}
for index,dots in pairs(dot_table) do
    for direction_index,directions in pairs(directional_table) do
        local current_entity = util.table.deepcopy(base_entity)
        current_entity.type = "corpse"
        current_entity.name = dots .. directions
        current_entity.animation.shift = {0, -0.1}
        if direction_index == 1 then
            current_entity.final_render_layer = 'light-effect'
        end
        current_entity.animation.filename = '__PickerPipeTools__/graphics/entity/markers/' .. dot_image_table[index] .. directions .. '.png'
        new_dots[#new_dots + 1] = current_entity
    end
end


for _,stuff in pairs(new_dots) do
    data:extend{
        merge{
            base_entity,
            stuff
        }
    }
end


data:extend {
    --new_dots,
    merge {
        base_entity,
        {
            name = 'picker-pipe-marker-box-good',
            icon = '__PickerPipeTools__/graphics/entity/markers/32x32highlighter.png',
            --time_before_removed = 60 * 20,
            collision_box = {{0, 0}, {0, 0}},
            final_render_layer = 'selection-box',
            animation = {
                width = 64,
                height = 64,
                frame_count = 1,
                direction_count = 1,
                scale = 0.5,
                shift = {-0.5, -0.5},
                filename = '__PickerPipeTools__/graphics/entity/markers/32x32highlighter.png'
            }
        }
    },
    merge {
        base_entity,
        {
            name = 'picker-pipe-marker-box-bad',
            icon = '__PickerPipeTools__/graphics/entity/markers/32x32highlighterbad.png',
            --time_before_removed = 60 * 20,
            collision_box = {{0, 0}, {0, 0}},
            final_render_layer = 'selection-box',
            animation = {
                width = 64,
                height = 64,
                frame_count = 1,
                direction_count = 1,
                scale = 0.5,
                shift = {-0.5, -0.5},
                filename = '__PickerPipeTools__/graphics/entity/markers/32x32highlighterbad.png'
            }
        }
    },
    merge {
        base_entity,
        {
            name = 'picker-underground-pipe-marker-horizontal',
            icon = '__PickerPipeTools__/graphics/entity/markers/underground-lines-single-horizontal.png',
            --time_before_removed = 60 * 20,
            collision_box = {{0, 0}, {0, 0}},
            final_render_layer = 'selection-box',
            animation = {
                width = 64,
                height = 64,
                frame_count = 1,
                direction_count = 1,
                --scale = 0.5,
                shift = {-0.5, -0.5},
                filename = '__PickerPipeTools__/graphics/entity/markers/underground-lines-single-horizontal.png'
            }
        }
    },
    merge {
        base_entity,
        {
            name = 'picker-underground-pipe-marker-vertical',
            icon = '__PickerPipeTools__/graphics/entity/markers/underground-lines-single-vertical.png',
            --time_before_removed = 60 * 20,
            collision_box = {{0, 0}, {0, 0}},
            final_render_layer = 'selection-box',
            animation = {
                width = 64,
                height = 64,
                frame_count = 1,
                direction_count = 1,
                --scale = 0.5,
                shift = {-0.5, -0.5},
                filename = '__PickerPipeTools__/graphics/entity/markers/underground-lines-single-vertical.png'
            }
        }
    },
    merge {
        base_entity,
        {
            name = 'picker-pipe-marker-ew',
            icon = '__PickerPipeTools__/graphics/entity/markers/pipe-marker-horizontal.png',
            --time_before_removed = 60 * 20,
            collision_box = {{0, 0}, {0, 0}},
            final_render_layer = 'collision-selection-box',
            animation = {
                width = 32,
                height = 32,
                frame_count = 1,
                direction_count = 1,
                ----scale = 0.5,
                shift = {0, -0.6},
                filename = '__PickerPipeTools__/graphics/entity/markers/pipe-marker-horizontal.png'
            }
        }
    },
    merge {
        base_entity,
        {
            name = 'picker-pipe-marker-ns',
            icon = '__PickerPipeTools__/graphics/entity/markers/pipe-marker-vertical.png',
            --time_before_removed = 60 * 20,
            collision_box = {{0, 0}, {0, 0}},
            final_render_layer = 'collision-selection-box',
            animation = {
                width = 32,
                height = 32,
                frame_count = 1,
                direction_count = 1,
                ----scale = 0.5,
                shift = {-0.5, -0.1},
                filename = '__PickerPipeTools__/graphics/entity/markers/pipe-marker-vertical.png'
            }
        }
    },
    merge {
        base_entity,
        {
            name = 'picker-pipe-marker-good-ew',
            icon = '__PickerPipeTools__/graphics/entity/markers/pipe-marker-horizontal-good.png',
            --time_before_removed = 60 * 20,
            collision_box = {{0, 0}, {0, 0}},
            final_render_layer = 'collision-selection-box',
            animation = {
                width = 32,
                height = 32,
                frame_count = 1,
                direction_count = 1,
                ----scale = 0.5,
                shift = {0, -0.6},
                filename = '__PickerPipeTools__/graphics/entity/markers/pipe-marker-horizontal-good.png'
            }
        }
    },
    merge {
        base_entity,
        {
            name = 'picker-pipe-marker-good-ns',
            icon = '__PickerPipeTools__/graphics/entity/markers/pipe-marker-vertical-good.png',
            --time_before_removed = 60 * 20,
            collision_box = {{0, 0}, {0, 0}},
            final_render_layer = 'collision-selection-box',
            animation = {
                width = 32,
                height = 32,
                frame_count = 1,
                direction_count = 1,
                ----scale = 0.5,
                shift = {-0.5, -0.1},
                filename = '__PickerPipeTools__/graphics/entity/markers/pipe-marker-vertical-good.png'
            }
        }
    },
    merge {
        base_entity,
        {
            name = 'picker-pipe-marker-bad-ew',
            icon = '__PickerPipeTools__/graphics/entity/markers/pipe-marker-horizontal-bad.png',
            --time_before_removed = 60 * 20,
            collision_box = {{0, 0}, {0, 0}},
            final_render_layer = 'collision-selection-box',
            animation = {
                width = 32,
                height = 32,
                frame_count = 1,
                direction_count = 1,
                ----scale = 0.5,
                shift = {0, -0.6},
                filename = '__PickerPipeTools__/graphics/entity/markers/pipe-marker-horizontal-bad.png'
            }
        }
    },
    merge {
        base_entity,
        {
            name = 'picker-pipe-marker-bad-ns',
            icon = '__PickerPipeTools__/graphics/entity/markers/pipe-marker-vertical-bad.png',
            --time_before_removed = 60 * 20,
            collision_box = {{0, 0}, {0, 0}},
            final_render_layer = 'collision-selection-box',
            animation = {
                width = 32,
                height = 32,
                frame_count = 1,
                direction_count = 1,
                ----scale = 0.5,
                shift = {-0.5, -0.1},
                filename = '__PickerPipeTools__/graphics/entity/markers/pipe-marker-vertical-bad.png'
            }
        }
    },
--------------------------------------------------------------------------------------------------------

}
