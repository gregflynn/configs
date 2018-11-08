local awful     = require("awful")
local lain      = require("lain")
local beautiful = require("beautiful")
local wibox     = require("wibox")
local gears     = require("gears")

local FontIcon = require("util/fonticon")

local colors = beautiful.colors
local dpi    = beautiful.xresources.apply_dpi


local font_icon_headphones = "\u{f7ca}"
local font_icon_mute = "\u{fc5d}"
local font_icon_low = "\u{f026}"
local font_icon_med = "\u{f027}"
local font_icon_high = "\u{f028}"

local volume_font_icon = FontIcon()
local tooltip = awful.tooltip {}

local volume = lain.widget.pulsebar {
    width = dpi(60),
    margins = 4,
    paddings = 0,
    notification_preset = {
        font = "Hack 10"
    },
    colors = {
        background = beautiful.colors.gray,
        mute       = beautiful.colors.purple,
        unmute     = beautiful.colors.orange
    },
    settings = function()
        if volume_now.muted == "yes" then
            tooltip.text = "Muted"
            volume_font_icon:update(font_icon_mute, colors.purple)
        else
            local level = tonumber(volume_now.left)

            if volume_now.index ~= "0" then
                volume_font_icon:update(font_icon_headphones, colors.orange)
                tooltip.text = string.format("Headphones: %s%%", level)
            else
                tooltip.text = string.format("Speakers: %s%%", level)
                if level < 30 then
                    volume_font_icon:update(font_icon_low, colors.orange)
                elseif level < 60 then
                    volume_font_icon:update(font_icon_med, colors.orange)
                else
                    volume_font_icon:update(font_icon_high, colors.orange)
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

-- round the corners
volume.bar.shape = beautiful.border_shape
volume.bar.bar_shape = beautiful.border_shape

volume.bar:buttons(volume.buttons)
volume_font_icon:buttons(volume.buttons)

volume.container = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    volume_font_icon,
    wibox.container.margin(volume.bar, dpi(0), dpi(3), dpi(3), dpi(3))
}

volume.tooltip:remove_from_object(volume.bar)
tooltip:add_to_object(volume.container)

return volume
