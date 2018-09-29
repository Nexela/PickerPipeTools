local Event = require('lib/event')
Event.protected_mode = true

require('lib/area')
require('lib/position')

require('lib/player').register_events(true)

--(( Load Scripts ))--
require('scripts/orphans')
require('scripts/pipe-highlight')
require('scripts/pipe-cleaner')
require('scripts/pipe-clamps')
--)) Load Scripts ((--
