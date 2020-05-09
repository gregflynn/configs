local display   = require('sanity/util/display')

local systray = require('wibox.widget.systray')
local margin   = require('wibox.container.margin')

local tray = systray()
tray:set_horizontal(false)
tray:set_base_size(36)

return margin(display.center(tray), 0, 0, 5, 5)
