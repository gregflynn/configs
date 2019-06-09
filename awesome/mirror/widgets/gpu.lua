local awful     = require('awful')
local beautiful = require('beautiful')
local gears     = require('gears')
local wibox     = require('wibox')

local lain    = require('lain')
local vicious = require('vicious')

local file     = require('util/file')
local text     = require('util/text')
local FontIcon = require('util/fonticon')
local Graph    = require('util/graph')

local dpi = beautiful.xresources.apply_dpi


local color = beautiful.colors.green
local gpu_icon = FontIcon {icon = '\u{f878}', color = color}
local gpu_temp
local gpu_graph_container

if file.exists("/usr/bin/nvidia-smi") and not file.exists("/proc/acpi/bbswitch") then
    gpu_temp = awful.widget.watch(
        "nvidia-smi --format=csv,nounits,noheader --query-gpu=temperature.gpu",
        15,
        function(widget, stdout)
            widget:set_markup(
                string.format('<span color="%s">%s°</span>', color, text.trim(stdout))
            )
        end
    )

    local gpu_graph = Graph {tooltip_text = 'GPU Usage', color = color}
    gpu_graph_container = gpu_graph.container

    local gpu_load_command = "nvidia-smi --format=csv,nounits,noheader --query-gpu=utilization.gpu"
    local gpu_load_widget = awful.widget.watch(
        gpu_load_command,
        2,
        function(widget, stdout)
            if stdout == nil or tonumber(stdout) == nil then
                return
            end
            widget:add_value(tonumber(stdout) / 100.0)
        end,
        gpu_graph
    )
end

local menu = awful.menu({
    theme = {width = dpi(150)},
    items = {
        {'Toggle Redshift', function() lain.widget.contrib.redshift:toggle() end}
    }
})

local container = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    gpu_icon,
    gpu_temp,
    gpu_graph_container,
    buttons = gears.table.join(
        awful.button({ }, 1, function() menu:toggle() end)
    )
}
return wibox.container.margin(container, 0, dpi(4), 0, 0)
