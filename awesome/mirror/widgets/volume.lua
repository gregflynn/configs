local awful     = require("awful")
local lain      = require("lain")
local beautiful = require("beautiful")
local wibox     = require("wibox")
local gears     = require("gears")

local music           = require('util/music')
local FontIcon        = require('util/fonticon')
local SanityContainer = require('util/sanitycontainer')
local gpmdp           = require('widgets/gpmdp')

local colors = beautiful.colors
local dpi    = beautiful.xresources.apply_dpi
local naughty = require('naughty')


local font_icon_headphones = "\u{f7ca}"
local font_icon_mute = "\u{fc5d}"
local font_icon_low = "\u{f026}"
local font_icon_med = "\u{f027}"
local font_icon_high = "\u{f028}"
local icon_running_paused = '\u{f04c}'
local icon_running_playing = '\u{f001}'

local tooltip = awful.tooltip {}
local fg_color = colors.blue

local icon = FontIcon {icon = font_icon_med, color = fg_color}
local volume = lain.widget.pulsebar {
    width = dpi(50),
    margins = 4,
    paddings = 0,
    notification_preset = {
        position = 'bottom_middle',
        title    = 'volume',
        font     = 'Hack 12'
    },
    colors = {
        background = beautiful.colors.gray,
        mute       = fg_color,
        unmute     = fg_color
    },
    settings = function()
        update_volume(volume_now)
    end
}
volume.bar.shape = beautiful.border_shape
volume.bar.bar_shape = beautiful.border_shape
volume.tooltip:remove_from_object(volume.bar)

local menu = awful.menu({
    theme = { width = 140 },
    items = {
        {'Volume Control', function() awful.spawn('pavucontrol') end},
        {'Equalizer', function() awful.spawn('pulseeffects') end},
        {'Bluetooth', function() awful.spawn('blueberry') end}
    }
})

volume_container = SanityContainer {
    widget = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        icon,
        wibox.container.margin(volume.bar, dpi(0), dpi(0), dpi(4), dpi(4)),
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
    music.get_current_track(function(current)
        local is_muted = volume_now.muted == 'yes'

        -- tooltips
        local vol_tooltip = 'Muted'
        if not is_muted then
            local level = tonumber(volume_now.left)
            vol_tooltip = string.format('Speakers: %s%%', level)
        end

        if current then
            local music_tooltip = gpmdp.get_tooltip(current)
            volume_container:set_markup(string.format('%s\n\n%s', vol_tooltip, music_tooltip))

            
        else
            volume_container:set_markup(vol_tooltip)
        end
        
        -- icon
        if is_muted then
            icon:update(font_icon_mute, fg_color)
        else
            if current then
                if current.playing then
                    icon:update(icon_running_playing, fg_color)
                else
                    icon:update(icon_running_paused, fg_color)
                end
            else
                icon:update(font_icon_high, fg_color)
            end
        end
        
        -- notifications
        if current then
            gpmdp.update_notification(current)
        end
    end)
end

return volume_container
