local awful = require("awful")
local lain = require("lain")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi

local volume = lain.widget.pulsebar {
    width = dpi(100),
    notification_preset = {
        font = "Hack 10"
    },
    colors = {
        background = beautiful.bg_normal,
        mute = beautiful.fg_urgent,
        unmute = beautiful.fg_focus
    }
}
volume.bar.paddings = dpi(5)
volume.bar:buttons(awful.util.table.join(
    awful.button({}, 1, function() -- left click
        awful.spawn("pavucontrol")
    end),
    awful.button({}, 3, function() -- right click
        awful.spawn(string.format("pactl set-sink-mute %d toggle", volume.sink))
        volume.update()
    end),
    awful.button({}, 4, function() -- scroll up
        awful.spawn(string.format("pactl set-sink-volume %d +1%%", volume.sink))
        volume.update()
    end),
    awful.button({}, 5, function() -- scroll down
        awful.spawn(string.format("pactl set-sink-volume %d -1%%", volume.sink))
        volume.update()
    end)
))

return wibox.container.background(volume.bar, beautiful.border_focus, gears.shape.rectangle)
