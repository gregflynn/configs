local awful     = require("awful")
local lain      = require("lain")
local beautiful = require("beautiful")
local wibox     = require("wibox")
local gears     = require("gears")

local FontIcon = require("util/fonticon")

local colors = beautiful.colors
local dpi    = beautiful.xresources.apply_dpi

local gpmdp = require("widgets/gpmdp")

local tooltip = awful.tooltip {}
local fg_color = colors.blue

local volume = lain.widget.pulsebar {
    width = dpi(50),
    margins = 4,
    paddings = 0,
    notification_preset = {
        position = "bottom_middle",
        title    = "volume",
        font     = "Hack 12"
    },
    colors = {
        background = beautiful.colors.gray,
        mute       = fg_color,
        unmute     = fg_color
    },
    settings = function()
        if volume_now.muted == "yes" then
            tooltip.text = "Muted"
        else
            local level = tonumber(volume_now.left)
            tooltip.text = string.format("Speakers: %s%%", level)
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

local container = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    gpmdp,
    wibox.container.margin(volume.bar, dpi(0), dpi(0), dpi(5), dpi(5)),
}
volume.bar.shape = beautiful.border_shape
volume.bar.bar_shape = beautiful.border_shape
volume.bar:buttons(volume.buttons)
tooltip:add_to_object(container)
volume.tooltip:remove_from_object(volume.bar)

container.globalkeys = gears.table.join(
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

local real_container = wibox.container.margin(container, 0, beautiful.widget_space, 0, 0)
real_container.globalkeys = container.globalkeys
return real_container
