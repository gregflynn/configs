local awful     = require("awful")
local lain      = require("lain")
local beautiful = require("beautiful")
local wibox     = require("wibox")
local gears     = require("gears")
local dpi       = beautiful.xresources.apply_dpi

-- elementary icons
local speaker_icon = "/usr/share/icons/elementary/devices/48/audio-speaker-left-back-testing.svg"
local mute_icon = "/usr/share/icons/elementary/devices/48/audio-speaker-left-back.svg"

-- Adwaita icon because elementary doesn't have a headphones icon
local headphones_icon = "/usr/share/icons/Adwaita/48x48/devices/audio-headphones.png"

local volume_icon = wibox.widget {
    image = speaker_icon,
    resize = true,
    widget = wibox.widget.imagebox
}

local volume = lain.widget.pulsebar {
    width = dpi(6),
    notification_preset = {
        font = "Hack 10"
    },
    colors = {
        background = beautiful.fg_normal,
        mute       = beautiful.fg_urgent,
        unmute     = beautiful.fg_focus
    },
    settings = function()
        if volume_now.muted == "yes" then
            volume_icon.image = mute_icon
        else
            if volume_now.index ~= "0" then
                volume_icon.image = headphones_icon
            else
                volume_icon.image = speaker_icon
            end
        end
    end
}

volume.buttons = awful.util.table.join(
    awful.button({}, 1, function() -- left click
        awful.spawn("pavucontrol")
    end),
    awful.button({}, 3, function() -- right click
        awful.spawn(string.format("pactl set-sink-mute %d toggle", volume.device))
        volume.update()
    end),
    awful.button({}, 4, function() -- scroll up
        awful.spawn(string.format("pactl set-sink-volume %d +1%%", volume.device))
        volume.update()
    end),
    awful.button({}, 5, function() -- scroll down
        awful.spawn(string.format("pactl set-sink-volume %d -1%%", volume.device))
        volume.update()
    end)
)

volume.globalkeys = gears.table.join(
    awful.key({ }, "XF86AudioRaiseVolume", function ()
        awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%")
        volume.notify()
    end),
    awful.key({ }, "XF86AudioLowerVolume", function ()
        awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%")
        volume.notify()
    end),
    awful.key({ }, "XF86AudioMute", function ()
        awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
        volume.notify()
    end)
)

volume.bar.paddings = 0
volume.bar:buttons(volume.buttons)
volume_icon:buttons(volume.buttons)

volume.widget = wibox.widget {
    volume.bar,
    forced_width  = dpi(6),
    direction     = 'east',
    layout        = wibox.container.rotate
}

volume.container = {
    layout = wibox.layout.fixed.horizontal,
    wibox.container.margin(volume_icon,    dpi(0),  dpi(3), dpi(4), dpi(4)),
    wibox.container.margin(volume.widget,  dpi(0), dpi(10), dpi(4), dpi(4))
}

return volume
