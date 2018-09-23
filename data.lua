data:extend{
    {
        type = 'custom-input',
        name = 'picker-show-underground-paths',
        key_sequence = 'CONTROL + SHIFT + P',
        consuming = 'script-only'
    },
    {
        type = "custom-input",
        name = "picker-toggle-pipe-clamp",
        key_sequence = "CONTROL + SHIFT + ALT + PAD 0",
        linked_game_control = 'rotate',
        consuming = "script-only"
      }
}

require('prototypes/pipe-highlight')
require('prototypes/pipe-cleaner')