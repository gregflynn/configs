local string = string

local beautiful = require('beautiful')
local gears     = require('gears')
local Container = require('sanity/util/container')
local Pie       = require('sanity/util/pie')
local icon      = require('sanity/util/icon')
local text      = require('sanity/util/text')

local button   = require('awful.button')
local menu     = require('awful.menu')
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

local vol_pie  = Pie {
    color     = fg_color,
    icon      = font_icon_mute
}

local volume = pulsebar {
    width = 50,
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
    tick = '█',
    tick_pre = '',
    tick_post = '',
    tick_none = ' '
}

local vol_menu = menu({
    theme = { width = 170 },
    items = {
        {'Bluetooth', function() spawn('blueberry') end, icon.get_path('devices', 'bluetooth')},
        {'Media Player', function() spawn('plexmediaplayer --windowed --desktop') end, icon.get_path('apps', 'multimedia-audio-player')},
        {'Volume Control', function() spawn('pavucontrol') end, icon.get_path('devices', 'audio-card')},
        {'Mute', function()
            spawn(string.format('pactl set-sink-mute %d toggle', volume.device))
            volume.update()
        end}
    }
})

local volume_container = Container {
    widget  = vol_pie,
    color   = fg_color,
    buttons = gears.table.join(
        button({}, 1, function() vol_menu:toggle() end),
        button({}, 3, function() vol_menu:toggle() end),
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

    -- tooltips
    local state = 'Muted'
    local device = volume_now.device
    if is_muted then
        vol_pie:update_icon(font_icon_mute, fg_color)
        vol_pie:update(0, fg_color)
        volume_container:set_color(fg_color)
    else
        local level = tonumber(volume_now.left)
        local level_icon = font_icon_high
        state = string.format('%s%%', level)

        if text.split(device, ':')[1] == 'front' then
            -- default speaker device
            if level <= 30 then
                level_icon = font_icon_low
                color = fg_color
            elseif level <= 70 then
                level_icon = font_icon_med
                color = wn_color
            end
        else
            -- assume anything else is bluetooth headphones
            level_icon = font_icon_headphones
        end

        vol_pie:update(level / 100, color)
        vol_pie:update_icon(level_icon, color)
        volume_container:set_color(color)
    end

    volume_container:set_tooltip_color(' Volume ', string.format(' %s \n %s ', device, state))
end

return volume_container
