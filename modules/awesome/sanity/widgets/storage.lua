local wibox     = require('wibox')
local beautiful = require('beautiful')
local vicious   = require('vicious')
local Container = require('sanity/util/container')
local FontIcon  = require('sanity/util/fonticon')
local display   = require('sanity/util/display')

local fs_bar = wibox.widget {
    max_value        = 1,
    value            = 0,
    color            = colors.background,
    background_color = colors.gray,
    widget           = wibox.widget.progressbar,
    shape            = beautiful.border_shape,
}

vicious.register(fs_bar, vicious.widgets.fs, "${/ used_p}", 60)

return Container {
    widget = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        FontIcon {icon = '', color = colors.background},
        display.vertical_bar(fs_bar),
    },
    color   = colors.background,
    no_tooltip = true
}
