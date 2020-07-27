local button = require('awful.button')
local gears  = require('gears')
local spawn  = require('awful.spawn')

local Container  = require('sanity/util/container')
local DoubleWide = require('sanity/util/doublewide')
local FontIcon   = require('sanity/util/fonticon')


local color_on  = colors.green
local color_off = colors.red

local lock_icon     = ''
local lock_icon_on  = ''
local lock_icon_off = ''

local lock_container
local lock_font_icon = FontIcon {
    small = true,
    icon  = lock_icon,
    color = color_on
}
local lock_status_icon = FontIcon {
    small = true,
    icon  = lock_icon_on,
    color = color_on
}

local screen_lock_on = true

function toggle_screen_lock()
    if screen_lock_on then
        spawn({'xautolock', '-disable'})
        spawn({'xset', 's', 'off'})
        spawn({'xset', '-dpms'})
        lock_container:set_color(color_off)
        lock_font_icon:update(lock_icon, color_off)
        lock_status_icon:update(lock_icon_off, color_off)
    else
        spawn({'xautolock', '-enable'})
        spawn({'xset', 's', 'on'})
        spawn({'xset', '+dpms'})
        lock_container:set_color(color_on)
        lock_font_icon:update(lock_icon, color_on)
        lock_status_icon:update(lock_icon_on, color_on)
    end
    screen_lock_on = not screen_lock_on
end

lock_container = Container {
    color  = color_on,
    widget = DoubleWide {
        left_widget  = lock_font_icon,
        right_widget = lock_status_icon
    },
    buttons = gears.table.join(
        button({}, 1, toggle_screen_lock),
        button({}, 3, toggle_screen_lock)
    ),
    no_tooltip = true
}

return lock_container
