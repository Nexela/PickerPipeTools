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
        shift = {-0.5, -0.5},
        filename = '__PickerPipeTools__/graphics/entity/markers/32x32highlighter.png'
    }
}











data:extend {
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
                shift = {0, -0.5},
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
                shift = {-0.5, 0},
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
                shift = {0, -0.5},
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
                shift = {-0.5, 0},
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
                shift = {0, -0.5},
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
                shift = {-0.5, 0},
                filename = '__PickerPipeTools__/graphics/entity/markers/pipe-marker-vertical-bad.png'
            }
        }
    },
--------------------------------------------------------------------------------------------------------
    merge {
        base_entity,
        {
            name = 'picker-pipe-dot',
            icon = '__PickerPipeTools__/graphics/entity/markers/pipe-marker-dot.png',
            --time_before_removed = 60 * 20,
            collision_box = {{0, 0}, {0, 0}},
            final_render_layer = 'selection-box',
            animation = {
                width = 32,
                height = 32,
                frame_count = 1,
                direction_count = 1,
                ----scale = 0.5,
                shift = {-0.5, -0.5},
                filename = '__PickerPipeTools__/graphics/entity/markers/pipe-marker-dot.png'
            }
        }
    },
    merge {
        base_entity,
        {
            name = 'picker-pipe-dot-bad',
            icon = '__PickerPipeTools__/graphics/entity/markers/pipe-marker-dot-bad.png',
            --time_before_removed = 60 * 20,
            collision_box = {{0, 0}, {0, 0}},
            final_render_layer = 'selection-box',
            animation = {
                width = 32,
                height = 32,
                frame_count = 1,
                direction_count = 1,
                ----scale = 0.5,
                shift = {-0.5, -0.5},
                filename = '__PickerPipeTools__/graphics/entity/markers/pipe-marker-dot-bad.png'
            }
        }
    },
    merge {
        base_entity,
        {
            name = 'picker-pipe-dot-good',
            icon = '__PickerPipeTools__/graphics/entity/markers/pipe-marker-dot-good.png',
            --time_before_removed = 60 * 20,
            collision_box = {{0, 0}, {0, 0}},
            final_render_layer = 'selection-box',
            animation = {
                width = 32,
                height = 32,
                frame_count = 1,
                direction_count = 1,
                ----scale = 0.5,
                shift = {-0.5, -0.5},
                filename = '__PickerPipeTools__/graphics/entity/markers/pipe-marker-dot-good.png'
            }
        }
    },
--[[    merge {
        base_entity,
        {
            name = 'picker-pipe-marker-good-ew',
            icon = '__PickerPipeTools__/graphics/entity/markers/pipe-marker-horizontal-good.png',
            --time_before_removed = 60 * 20,
            collision_box = {{0, 0}, {0, 0}},
            final_render_layer = 'selection-box',
            animation = {
                width = 32,
                height = 32,
                frame_count = 1,
                direction_count = 1,
                ----scale = 0.5,
                shift = {0, -0.5},
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
            final_render_layer = 'selection-box',
            animation = {
                width = 32,
                height = 32,
                frame_count = 1,
                direction_count = 1,
                ----scale = 0.5,
                shift = {-0.5, 0},
                filename = '__PickerPipeTools__/graphics/entity/markers/pipe-marker-vertical-good.png'
            }
        }
    },]]--
}
