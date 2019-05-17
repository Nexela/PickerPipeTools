<<<<<<< HEAD
require('prototypes/pipe-highlight')
require('prototypes/pipe-cleaner')
require('prototypes/controls')
=======
data:extend {
    {
        type = 'custom-input',
        name = 'picker-show-underground-paths',
        key_sequence = 'CONTROL + SHIFT + P',
        consuming = 'script-only'
    },
    {
        type = 'custom-input',
        name = 'picker-toggle-pipe-clamp',
        key_sequence = 'CONTROL + SHIFT + ALT + PAD 0',
        linked_game_control = 'rotate',
        consuming = 'script-only'
    },
    {
        type = 'custom-input',
        name = 'picker-pipe-filter',
        key_sequence = 'CONTROL + F'
    }
}

require('prototypes/pipe-highlight')
require('prototypes/pipe-cleaner')
>>>>>>> 5cf9a65ae0f03e759ec114aabcf0a242d3e85ff2
