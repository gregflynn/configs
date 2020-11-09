local awful   = require('awful')
local systray = require('wibox.widget.systray')
local margin  = require('wibox.container.margin')
local fixed   = require('wibox.layout.fixed')
local gears   = require('gears')

local Container = require('sanity/util/container')
local FontIcon  = require('sanity/util/fonticon')

local expanded = false
local expanded_icon = ''
local expanded_color = colors.gray
local closed_color = colors.background
local tray = systray()

local tray_margin = margin(tray, 2, 2, 3, 3)
local toggle_font_icon = FontIcon {icon = expanded_icon, color = closed_color}
local toggle_container = Container {
    widget = toggle_font_icon,
    no_tooltip = true,
    color = closed_color
}
local container = {
    layout = fixed.horizontal,
    tray_margin,
    toggle_container,
}

function toggle_tray()
    expanded = not expanded
    tray_margin.visible = expanded

    if expanded then
        toggle_font_icon:update(expanded_icon, expanded_color)
        toggle_container:set_color(expanded_color)
    else
        toggle_font_icon:update(expanded_icon, closed_color)
        toggle_container:set_color(closed_color)
    end
end

tray_margin.visible = expanded
toggle_container:buttons(gears.table.join(
    awful.button({}, 1, function() toggle_tray() end),
    awful.button({}, 3, function() toggle_tray() end)
))

return container
