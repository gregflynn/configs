local awful     = require("awful")
local beautiful = require("beautiful")
local wibox     = require("wibox")

local vicious = require("vicious")

local FontIcon  = require("util/fonticon")

local colors = beautiful.colors
local dpi    = beautiful.xresources.apply_dpi


local cpu_chip_icon = FontIcon { icon = '\u{fb19}', color = colors.background }

local cpu_temp_widget = awful.widget.watch("sensors", 15, function(widget, stdout)
    local temp = stdout:match("Package id 0:%s+%p(%d+%p%d)")
    if not temp then
        temp = stdout:match("temp1:%s+%p(%d+%p%d)")
    end

    if temp then
        widget:set_markup(
            string.format(
                '<span color="%s">%s°C</span>',
                beautiful.colors.background,
                math.floor(temp)
            )
        )
    end
end)
awful.tooltip {
    objects = {cpu_temp_widget},
    text = "CPU Temp"
}

local cpu_load_widget = wibox.widget.graph {
    width = dpi(40),
}
cpu_load_widget.background_color = colors.red
cpu_load_widget.color = colors.background
vicious.register(cpu_load_widget, vicious.widgets.cpu, "$1")
awful.tooltip {
    objects = {cpu_load_widget},
    text = "CPU Load"
}

return wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    cpu_chip_icon,
    cpu_temp_widget,
    wibox.container.margin(cpu_load_widget, dpi(2), dpi(2), dpi(2), dpi(2))
}
