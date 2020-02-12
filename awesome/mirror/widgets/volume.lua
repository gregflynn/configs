local awful     = require("awful")
local lain      = require("lain")
local beautiful = require("beautiful")
local wibox     = require("wibox")
local gears     = require("gears")

local FontIcon        = require('util/fonticon')
local SanityContainer = require('util/sanitycontainer')
local Pie             = require('util/pie')

local colors = beautiful.colors
local dpi    = beautiful.xresources.apply_dpi

local font_icon_headphones = "\u{f7ca}"
local font_icon_mute = "\u{fc5d}"
local font_icon_low = "\u{f026}"
local font_icon_med = "\u{f027}"
local font_icon_high = "\u{f028}"
local fg_color = colors.blue
local vol_pie = Pie { colors = {fg_color}, thickness = 4}

local icon = FontIcon {icon = font_icon_med, color = fg_color}
local volume = lain.widget.pulsebar {
    width = dpi(50),
    margins = 4,
    paddings = 0,
    notification_preset = {
        position = 'bottom_middle',
        title    = 'volume',
        font     = beautiful.font_notif
    },
    colors = {
        background = beautiful.colors.gray,
        mute       = fg_color,
        unmute     = fg_color
    },
    settings = function()
        update_volume(volume_now)
    end,
    tick = "█",
    tick_pre = "\u{e0b2}",
    tick_post = "\u{e0b0}",
    tick_none = " "
}

local menu = awful.menu({
    theme = { width = 140 },
    items = {
        {'Volume Control', function() awful.spawn('pavucontrol') end},
        {'Bluetooth', function() awful.spawn('blueberry') end}
    }
})

volume_container = SanityContainer {
    widget = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        icon,
        vol_pie,
    },
    color = fg_color,
    buttons = gears.table.join(
        awful.button({}, 1, function() menu:toggle() end),
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
    ),
    globalkeys = gears.table.join(
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
}

function update_volume(volume_now)
    local is_muted = volume_now.muted == 'yes'

    -- tooltips
    local vol_tooltip = 'Muted'
    if is_muted then
        icon:update(font_icon_mute, fg_color)
        vol_pie:update(0)
    else
        local level = tonumber(volume_now.left)
        local level_icon = font_icon_high
        vol_tooltip = string.format('Speakers: %s%%', level)

        if volume_now.device == 'front:0' then
            -- default speaker device
            if level <= 30 then
                level_icon = font_icon_low
            elseif level <= 70 then
                level_icon = font_icon_med
            end
        else
            -- assume anything else is bluetooth headphones
            level_icon = font_icon_headphones
        end

        icon:update(level_icon, fg_color)
        vol_pie:update(level / 100)
    end

    volume_container:set_markup(vol_tooltip)
end

return volume_container
