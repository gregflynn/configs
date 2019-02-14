local awful     = require("awful")
local beautiful = require("beautiful")
local gears     = require("gears")
local wibox     = require("wibox")
local lain      = require("lain")
local markup    = lain.util.markup


local clock = wibox.widget.textclock(markup.fg.color(
    beautiful.colors.background, '%a %m/%d %l:%M%P'
))

awful.tooltip {
    objects = {clock},
    text    = "Show Cal / Open Cal"
}

local calendar = lain.widget.cal {
    attach_to = { clock },
    week_start = 1,
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
    awful.button({ }, 1, calendar.hover_on),
    awful.button({ }, 2, calendar.hover_on),
    awful.button({ }, 3, function()
        awful.spawn("xdg-open https://calendar.google.com/")
    end),
    awful.button({ }, 5, calendar.prev),
    awful.button({ }, 4, calendar.next)
))


return clock
