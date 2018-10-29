local awful     = require("awful")
local lain      = require("lain")
local beautiful = require("beautiful")
local wibox     = require("wibox")
local gears     = require("gears")

local bar = require("util/bar")
local fonticon = require("util/fonticon")

local colors = beautiful.colors
local dpi    = beautiful.xresources.apply_dpi


local font_icon_headphones = "\u{f7ca}"
local font_icon_mute = "\u{fc5d}"
local font_icon_low = "\u{f026}"
local font_icon_med = "\u{f027}"
local font_icon_high = "\u{f028}"

local volume_font_icon = fonticon.create()

local volume = lain.widget.pulsebar {
    width = dpi(60),
    ticks = true,
    tick_size = dpi(5),
    notification_preset = {
        font = "Hack 10"
    },
    colors = {
        background = beautiful.colors.background,
        mute       = beautiful.colors.blue,
        unmute     = beautiful.colors.green
    },
    settings = function()
        if volume_now.muted == "yes" then
            fonticon.update(volume_font_icon, font_icon_mute, colors.blue)
        else
            if volume_now.index ~= "0" then
                fonticon.update(volume_font_icon, font_icon_headphones, colors.purple)
            else
                local level = tonumber(volume_now.left)

                if level < 30 then
                    fonticon.update(volume_font_icon, font_icon_low, colors.green)
                elseif level < 60 then
                    fonticon.update(volume_font_icon, font_icon_med, colors.green)
                else
                    fonticon.update(volume_font_icon, font_icon_high, colors.green)
                end
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
    awful.key({ }, "XF86AudioRaiseVolume", function()
        awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%")
        volume.notify()
    end),
    awful.key({ }, "XF86AudioLowerVolume", function()
        awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%")
        volume.notify()
    end),
    awful.key({ }, "XF86AudioMute", function()
        awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
        volume.notify()
    end)
)

volume.bar:buttons(volume.buttons)
volume_font_icon:buttons(volume.buttons)

volume.container = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    wibox.container.margin(volume_font_icon, dpi(0),  dpi(3)),
    wibox.container.margin(volume.bar, dpi(0), dpi(3), dpi(3), dpi(3))
}

return volume
