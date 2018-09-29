local Data = require('__stdlib__/stdlib/data/data')

local pipe = Data('wall-remnants', 'corpse'):copy('picker-underground-marker-horizontal'):set_fields {
    icon = '__PickerPipeTools__/graphics/boxes/underground-lines-single-horizontal.png',
    time_before_removed = 60 * 10,
    collision_box = {{0, 0}, {0, 0}},
    final_render_layer = 'selection-box',
    animation = {
        width = 64,
        height = 64,
        frame_count = 1,
        direction_count = 1,
        scale = 0.5,
        filename = '__PickerPipeTools__/graphics/boxes/underground-lines-single-horizontal.png'
    }
}
pipe:Flags():add{'placeable-off-grid', 'not-repairable', 'not-on-map', 'not-blueprintable', 'not-deconstructable'}:remove('placeable-neutral')

local ver = pipe:copy('picker-underground-marker-vertical')
ver.animation.filename = '__PickerPipeTools__/graphics/boxes/underground-lines-single-vertical.png'
ver.icon = '__PickerPipeTools__/graphics/boxes/underground-lines-single-vertical.png'
