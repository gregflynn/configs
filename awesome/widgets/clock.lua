local wibox = require("wibox")
local beautiful = require("beautiful")
local lain = require("lain")

local clock = wibox.widget.textclock(
    '<span color="'..beautiful.fg_minimize..'">%a %b %e %l:%M%P</span>'
)

lain.widget.calendar {
    attach_to = { clock },
    icons = '',
    notification_preset = {
        font = 'Hack',
        fg = beautiful.fg_normal,
        bg = beautiful.bg_normal
    },
    cal = "/usr/bin/env TERM=linux /usr/bin/cal --color=always"
}

return clock
