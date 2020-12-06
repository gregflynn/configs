local button = require('awful.button')
local gears  = require('gears')
local spawn  = require('awful.spawn')

local Container  = require('sanity/util/container')
local FontIcon   = require('sanity/util/fonticon')


local color_on  = colors.white
local color_off = colors.red

local lock_icon     = ''

local lock_font_icon = FontIcon {
    small = true,
    icon  = lock_icon,
    color = color_on
}

local screen_lock_on = true

function toggle_screen_lock()
    if screen_lock_on then
        spawn({'xautolock', '-disable'})
        spawn({'xset', 's', 'off'})
        spawn({'xset', '-dpms'})
        lock_font_icon:update(lock_icon, color_off)
    else
        spawn({'xautolock', '-enable'})
        spawn({'xset', 's', 'on'})
        spawn({'xset', '+dpms'})
        lock_font_icon:update(lock_icon, color_on)
    end
    screen_lock_on = not screen_lock_on
end

local lock_container = Container {
    color  = color_on,
    widget  = lock_font_icon,
    buttons = gears.table.join(
        button({}, 1, toggle_screen_lock),
        button({}, 3, toggle_screen_lock)
    ),
    no_tooltip = true
}

return lock_container
