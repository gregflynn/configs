local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local vicious = require('vicious')

local FontIcon        = require('util/fonticon')
local Graph           = require('util/graph')
local SanityContainer = require('util/sanitycontainer')

local dpi = beautiful.xresources.apply_dpi


local color = beautiful.colors.red
local cpu_icon = FontIcon {icon = '\u{fb19}', color = color}
local cpu_temp_widget = awful.widget.watch("sensors", 15, function(widget, stdout)
    local temp = stdout:match("Package id 0:%s+%p(%d+%p%d)")
    if not temp then
        temp = stdout:match("temp1:%s+%p(%d+%p%d)")
    end

    if temp then
        widget:set_markup(
            string.format('<span color="%s">%s°</span>', color, math.floor(temp))
        )
    end
end)

local cpu_load_widget = Graph {color = color}
vicious.register(cpu_load_widget, vicious.widgets.cpu, "$1")

return SanityContainer {
    widget = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        cpu_icon,
        cpu_temp_widget,
        cpu_load_widget.container
    },
    color = color,
    tooltip = 'CPU Usage'
}
