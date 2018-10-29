local awful     = require("awful")
local gears     = require("gears")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local lain      = require("lain")


local clock = wibox.widget.textclock(
    '<span color="'..beautiful.colors.background..'">%a %b %d %l:%M%P</span>'
)

awful.tooltip {
    objects = {clock},
    text    = "Show Cal / Open Cal"
}

local calendar = lain.widget.cal {
    attach_to = { clock },
    icons = "",
    notification_preset = {
        font = 'Hack',
        fg = beautiful.fg_normal,
        bg = beautiful.bg_normal
    },
    cal = "/usr/bin/env TERM=linux /usr/bin/cal --color=always"
}

clock:disconnect_signal("mouse::enter", calendar.hover_on)

clock:buttons(gears.table.join(
    awful.button({ }, 1, calendar.prev),
    awful.button({ }, 2, calendar.hover_on),
    awful.button({ }, 3, function()
        awful.spawn("xdg-open https://calendar.google.com/")
    end),
    awful.button({ }, 5, calendar.prev),
    awful.button({ }, 4, calendar.next)
))


return clock
