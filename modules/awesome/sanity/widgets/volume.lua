local string    = string
local wibox     = require('wibox')
local awful     = require('awful')
local beautiful = require('beautiful')
local gears     = require('gears')
local Container = require('sanity/util/container')
local FontIcon  = require('sanity/util/fonticon')
local text      = require('sanity/util/text')
local pulsebar  = require('lain.widget.pulsebar')
local display   = require('sanity/util/display')

local font_icon_headphones = '\u{f7ca}'
local font_icon_mute       = '\u{fc5d}'
local font_icon_low        = '\u{f026}'
local font_icon_med        = '\u{f027}'
local font_icon_high       = '\u{f028}'

local fg_color = colors.background
local al_color = colors.red

local vol_icon = FontIcon {small = true, color = fg_color, icon = font_icon_mute}

local volume = pulsebar {
    height = 8,
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
    tick = '=',
}
volume.bar.shape = beautiful.border_shape
volume.bar.paddings = 0
volume.bar.margins = 0

function toggle_mute()
    awful.spawn(string.format('pactl set-sink-mute %d toggle', volume.device))
    volume.update()
end

local volume_container = Container {
    widget = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        vol_icon,
        display.vertical_bar(volume.bar)
    },
    no_tooltip = true,
    color   = fg_color,
    buttons = gears.table.join(
        awful.button({}, 1, toggle_mute),
        awful.button({}, 3, toggle_mute),
        awful.button({}, 4, function()
            awful.spawn(string.format('pactl set-sink-volume %d +1%%', volume.device))
            volume.update()
        end),
        awful.button({}, 5, function()
            awful.spawn(string.format('pactl set-sink-volume %d -1%%', volume.device))
            volume.update()
        end)
    ),
}
volume_container.lain_widget = volume

function update_volume(volume_now)
    local is_muted = volume_now.muted == 'yes'
    local color    = al_color
    local level = tonumber(volume_now.left)
    local level_icon = font_icon_high

    local device = volume_now.device
    if is_muted then
        color = colors.gray
        level = 0
        level_icon = font_icon_mute
    else
        if #text.split(device, ':') == 6 then
            level_icon = font_icon_headphones
        else
            -- default speaker device
            if level <= 60 then
                level_icon = font_icon_low
                color = fg_color
            elseif level <= 75 then
                level_icon = font_icon_med
                color = fg_color
            end
        end
        level = level / 100
    end
    vol_icon:update(level_icon, color)
    volume_container:set_color(color)
    volume.bar.color = color
end

return volume_container
