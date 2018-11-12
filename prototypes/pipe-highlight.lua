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
local empty_sprite =
{
  filename = "__core__/graphics/empty.png",
  priority = "extra-high",
  width = 1,
  height = 1,
  frame_count = 1
}

local underground_marker_beam_table = {
    ['picker-pipe-marker-beam'] = 'pipe-marker-horizontal',
    ['picker-pipe-marker-beam-good'] = 'pipe-marker-horizontal-good',
    ['picker-pipe-marker-beam-bad'] = 'pipe-marker-horizontal-bad'
}
local underground_marker_beams = {}
for beam_type, marker_name in pairs(underground_marker_beam_table) do
    local marker_beams = util.table.deepcopy(data.raw['beam']['electric-beam-no-sound'])
    marker_beams.name = beam_type
    marker_beams.width = 1.0
    marker_beams.damage_interval = 2000000000
    marker_beams.action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "damage",
            damage = { amount = 0, type = "electric"}
          }
        }
      }
    }
    marker_beams.start = {
        filename = "__core__/graphics/empty.png",
        line_length = 1,
        width = 1,
        height = 1,
        frame_count = 1,
        axially_symmetrical = false,
        direction_count = 1,
        --shift = {-0.03125, 0},
        hr_version =
        {
            filename = "__core__/graphics/empty.png",
            line_length = 1,
            width = 1,
            height = 1,
            frame_count = 1,
            axially_symmetrical = false,
            direction_count = 1,
            --shift = {0.53125, 0},
            --scale = 0.5
        }
    }
    marker_beams.ending = {
        filename = "__core__/graphics/empty.png",
        line_length = 1,
        width = 1,
        height = 1,
        frame_count = 1,
        axially_symmetrical = false,
        direction_count = 1,
        --shift = {-0.03125, 0},
        hr_version =
        {
            filename = "__core__/graphics/empty.png",
            line_length = 1,
            width = 1,
            height = 1,
            frame_count = 1,
            axially_symmetrical = false,
            direction_count = 1,
            --shift = {0.53125, 0},
            --scale = 0.5
        }
    }
    marker_beams.head =
    {
        filename = "__PickerPipeTools__/graphics/entity/markers/" .. marker_name .. ".png",
        line_length = 1,
        width = 64,
        height = 64,
        frame_count = 1,
        animation_speed = 1,
        scale = 0.5
        --blend_mode = beam_blend_mode
    }
    marker_beams.tail =
    {
        filename = "__PickerPipeTools__/graphics/entity/markers/" .. marker_name .. ".png",
        line_length = 1,
        width = 64,
        height = 64,
        frame_count = 1,
        animation_speed = 1,
        scale = 0.5
        --blend_mode = beam_blend_mode
    }
    marker_beams.body =
    {
        {
            filename = "__PickerPipeTools__/graphics/entity/markers/" .. marker_name .. ".png",
            line_length = 1,
            width = 64,
            height = 64,
            frame_count = 1,
            scale = 0.5
            --blend_mode = beam_blend_mode
        }
    }
    underground_marker_beams[#underground_marker_beams + 1] = marker_beams
end

data:extend(
    underground_marker_beams
)

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

}
