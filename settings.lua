data:extend{
    {
        type = 'bool-setting',
        name = 'picker-find-orphans',
        setting_type = 'runtime-per-user',
        default_value = true,
        order = 'picker-b[find-orphans]-a'
    },
    {
        type = 'bool-setting',
        name = 'picker-tool-pipe-cleaner',
        setting_type = 'startup',
        default_value = true,
        order = 'tool-pipe-cleaner'
    },
    {
        type = 'int-setting',
        name = 'picker-max-checked-pipes',
        setting_type = 'runtime-global',
        minimum_value = 100,
        maximum_value = 5000,
        default_value = 250,
        order = 'picker-b'
    }
}
