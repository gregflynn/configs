local beautiful = require('beautiful')
local wibox     = require('wibox')
local vicious   = require('vicious')
local Container = require('sanity/util/container')
local FontIcon  = require('sanity/util/fonticon')
local display   = require('sanity/util/display')

local font_icon = FontIcon {icon = '', color = colors.white}
local cpu_bar = wibox.widget {
    max_value        = 1,
    value            = 0,
    color            = colors.white,
    background_color = colors.gray,
    widget           = wibox.widget.progressbar,
    shape            = beautiful.border_shape,
}
local cpu_container = Container {
    widget = font_icon,
    widget = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        font_icon,
        display.vertical_bar(cpu_bar),
    },
    no_tooltip = true,
}

vicious.register(cpu_bar, vicious.widgets.cpu, "$1", 1)

return cpu_container
