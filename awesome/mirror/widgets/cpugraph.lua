local awful     = require("awful")
local beautiful = require("beautiful")
local gears     = require("gears")
local wibox     = require("wibox")

local vicious = require("vicious")

local dpi = beautiful.xresources.apply_dpi


local cpuwidget = wibox.widget.graph()
cpuwidget:set_width(dpi(50))
cpuwidget:set_background_color(beautiful.bg_normal)
cpuwidget:set_color({
    type = "linear",
    from = { 0, 0 },
    to = { 0, 20 },
    stops = {
        { 0, beautiful.colors.red },
        { 1, beautiful.colors.green }
    }
})
vicious.register(cpuwidget, vicious.widgets.cpu, "$1")

awful.tooltip {
    objects = {cpuwidget},
    text = "CPU Load"
}

return wibox.container.background(
    cpuwidget, beautiful.border_focus, gears.shape.rectangle
)
