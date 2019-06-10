local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local vicious = require('vicious')

local text     = require('util/text')
local number   = require('util/number')
local FontIcon = require('util/fonticon')
local Graph    = require('util/graph')

local dpi = beautiful.xresources.apply_dpi


local color = beautiful.colors.yellow
local mem_icon = FontIcon {icon = '\u{f85a}', color = color}
local mem_graph = Graph {tooltip_text = 'Memory Usage', color = color}
vicious.register(mem_graph, vicious.widgets.mem, "$1")

awful.widget.watch(
    {awful.util.shell, '-c', "free -b | grep Mem | awk '{print $2,$3}'"},
    5,
    function(widget, stdout)
        local split = text.split(stdout)
        local total_bytes = tonumber(split[1])
        local used_bytes = tonumber(split[2])
        local used_raw_pct = used_bytes / total_bytes
        local pct_used = number.round(used_raw_pct * 100, 1)
        mem_graph.tooltip.text = string.format('%s%% Memory Used', pct_used)
    end
)

local container = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    mem_icon,
    mem_graph.container
}
return wibox.container.margin(container, 0, beautiful.widget_space, 0, 0)
