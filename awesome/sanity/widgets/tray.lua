local FontIcon  = require('sanity/util/fonticon')
local Container = require('sanity/util/container')

local popup   = require('awful.popup')
local fixed   = require('wibox.layout.fixed')
local widget  = require('wibox.widget')
local systray = require('wibox.widget.systray')

local color = colors.gray
local color_open = colors.yellow
local tray = systray()
tray.forced_width = 100
tray.forced_height = 28

local closed    = ''
local open      = ''
local gear_icon = FontIcon {icon = closed,   color = color, small = true}
local open_icon = FontIcon {icon = closed, color = color, small = true}

local p = popup {
    widget  = tray,
    ontop   = true,
    visible = false,
}

local tray_container = Container {
    widget = widget {
        layout = fixed.horizontal,
        gear_icon,
        open_icon,
    },
    color   = color,
    tooltip = ' System Tray ',
}

tray_container:connect_signal('button::press', function(_, _, _, button, _, geo)
    if button == 1 or button == 3 then
        if not p.visible then
            p:move_next_to(geo)
            gear_icon:update(open, color_open)
            open_icon:update(open, color_open)
            tray_container:set_color(color_open)
        else
            p.visible = false
            gear_icon:update(closed, color)
            open_icon:update(closed, color)
            tray_container:set_color(color)
        end
    end
end)

return tray_container
