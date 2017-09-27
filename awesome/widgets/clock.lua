local awful = require("awful")
local gears = require("gears")
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

clock:buttons(gears.table.join(
    -- NOTE: this kills lain's buttons
    awful.button({ }, 1, function()
        awful.spawn("google-chrome-stable https://calendar.google.com/")
    end)
))

return clock
