local string = string

local beautiful  = require('beautiful')
local gears      = require('gears')
local Container  = require('sanity/util/container')
local DoubleWide = require('sanity/util/doublewide')
local FontIcon   = require('sanity/util/fonticon')
local Pie        = require('sanity/util/pie')
local text       = require('sanity/util/text')

local button   = require('awful.button')
local spawn    = require('awful.spawn')
local pulsebar = require('lain.widget.pulsebar')

local font_icon_headphones = '\u{f7ca}'
local font_icon_mute       = '\u{fc5d}'
local font_icon_low        = '\u{f026}'
local font_icon_med        = '\u{f027}'
local font_icon_high       = '\u{f028}'

local fg_color = colors.blue
local wn_color = colors.yellow
local al_color = colors.red

local vol_icon = FontIcon {small = true, color = fg_color, icon = font_icon_mute}
local vol_pie  = Pie {
    color = fg_color,
    icon  = font_icon_mute
}

local volume = pulsebar {
    width = 50,
    margins = 4,
    paddings = 0,
    notification_preset = {
        position = 'bottom_left',
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
    tick = '█',
}

function toggle_mute()
    spawn(string.format('pactl set-sink-mute %d toggle', volume.device))
    volume.update()
end

local volume_container = Container {
    widget = DoubleWide {
        left_widget = vol_icon,
        right_widget = vol_pie,
    },
    no_tooltip = true,
    color   = fg_color,
    buttons = gears.table.join(
        button({}, 1, toggle_mute),
        button({}, 3, toggle_mute),
        button({}, 4, function()
            spawn(string.format('pactl set-sink-volume %d +1%%', volume.device))
            volume.update()
        end),
        button({}, 5, function()
            spawn(string.format('pactl set-sink-volume %d -1%%', volume.device))
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
            if level <= 40 then
                level_icon = font_icon_low
                color = fg_color
            elseif level <= 75 then
                level_icon = font_icon_med
                color = wn_color
            end
        end
        level = level / 100
    end
    vol_pie:update(level, color)
    vol_icon:update(level_icon, color)
    volume_container:set_color(color)
end

return volume_container
