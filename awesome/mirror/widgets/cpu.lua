local awful     = require("awful")
local beautiful = require("beautiful")
local wibox     = require("wibox")

local vicious = require("vicious")

local file = require("util/file")
local FontIcon = require("util/fonticon")
local text = require("util/text")

local colors = beautiful.colors
local dpi    = beautiful.xresources.apply_dpi


local function make_graph()
    local graph = wibox.widget.graph {
        width            = dpi(40),
    }
    graph.background_color = colors.red
    graph.color = colors.background
    return graph
end

local function graph_container(widget, tooltip_text)
    local container = wibox.container.margin(widget, dpi(2), dpi(2), dpi(2), dpi(2))
    awful.tooltip { objects = {container}, text = tooltip_text }
    return container
end

local container = wibox.widget { layout = wibox.layout.fixed.horizontal }

local cpu_temp_widget = awful.widget.watch("sensors", 15, function(widget, stdout)
    local temp = stdout:match("Package id 0:%s+%p(%d+%p%d)")
    if not temp then
        temp = stdout:match("temp1:%s+%p(%d+%p%d)")
    end

    if temp then
        widget:set_markup(string.format('<span color="%s">%s°C</span> ', colors.background, math.floor(temp)))
    end
end)
awful.tooltip {
    objects = {cpu_temp_widget},
    text = "CPU Temp"
}
if file.exists("/usr/bin/nvidia-smi") then
    container:add(FontIcon { icon = "\u{fb19}", color = colors.background })
end
container:add(cpu_temp_widget)

local cpu_load_widget = make_graph()
vicious.register(cpu_load_widget, vicious.widgets.cpu, "$1")
container:add(graph_container(cpu_load_widget, "CPU Load"))

if file.exists("/usr/bin/nvidia-smi") then
    container:add(FontIcon { icon = "\u{f878}", color = colors.background })
    local gpu_temp_command = "nvidia-smi --format=csv,nounits,noheader --query-gpu=temperature.gpu"
    local gpu_temp_widget = awful.widget.watch(gpu_temp_command, 15, function(widget, stdout)
        widget:set_markup(string.format(' <span color="%s">%s°C</span> ', colors.background, text.trim(stdout)))
    end)
    container:add(gpu_temp_widget)
    awful.tooltip {
        objects = {gpu_temp_widget},
        text = "GPU Temp"
    }

    local gpu_load_command = "nvidia-smi --format=csv,nounits,noheader --query-gpu=utilization.gpu"
    local gpu_load_widget = awful.widget.watch(gpu_load_command, 2, function(widget, stdout)
        if stdout == nil or tonumber(stdout) == nil then
            return
        end
        widget:add_value(tonumber(stdout) / 100.0)
    end, make_graph())
    container:add(graph_container(gpu_load_widget, "GPU Load"))
end

return container
