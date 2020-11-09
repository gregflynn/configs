local beautiful = require('beautiful')
local wibox     = require('wibox')
local vicious   = require('vicious')
local Container = require('sanity/util/container')
local FontIcon  = require('sanity/util/fonticon')
local display   = require('sanity/util/display')

local color   = colors.background
local mem_bar = wibox.widget {
    max_value        = 1,
    value            = 0,
    color            = colors.background,
    background_color = colors.gray,
    widget           = wibox.widget.progressbar,
    shape            = beautiful.border_shape,
}

vicious.register(mem_bar, vicious.widgets.mem, "$1", 5)

return Container {
    widget = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        FontIcon {icon = '', color = color, small = true},
        display.vertical_bar(mem_bar),
    },
    color = color,
    no_tooltip = true,
}
