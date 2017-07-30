local wibox = require("wibox")
local beautiful = require("beautiful")
local vicious = require("vicious")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi

local cpuwidget = wibox.widget.graph()
cpuwidget:set_width(dpi(50))
cpuwidget:set_background_color(beautiful.bg_normal)
cpuwidget:set_color({ type = "linear", from = { 0, 0 }, to = { 0, 20 }, stops = {
    { 0, beautiful.fg_urgent },
    { 1, beautiful.fg_focus }
}})
vicious.register(cpuwidget, vicious.widgets.cpu, "$1")

return wibox.container.background(cpuwidget, beautiful.border_focus, gears.shape.rectangle)
