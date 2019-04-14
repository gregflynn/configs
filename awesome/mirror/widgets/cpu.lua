local awful     = require("awful")
local beautiful = require("beautiful")
local wibox     = require("wibox")

local vicious = require("vicious")

local file = require("util/file")
local text = require("util/text")

local colors = beautiful.colors
local dpi    = beautiful.xresources.apply_dpi


local function make_graph()
    local graph = wibox.widget.graph {
        width = dpi(30),
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

local function temp_markup(widget, temp)
    widget:set_markup(
        string.format('<span color="%s">%s°</span>', colors.background, temp)
    )
end

local container = wibox.widget { layout = wibox.layout.fixed.horizontal }


--
-- CPU
--
local cpu_temp_widget = awful.widget.watch("sensors", 15, function(widget, stdout)
    local temp = stdout:match("Package id 0:%s+%p(%d+%p%d)")
    if not temp then
        temp = stdout:match("temp1:%s+%p(%d+%p%d)")
    end

    if temp then
        temp_markup(widget, math.floor(temp))
    end
end)
awful.tooltip { objects = {cpu_temp_widget}, text = "CPU Temp" }
container:add(cpu_temp_widget)

local cpu_load_widget = make_graph()
vicious.register(cpu_load_widget, vicious.widgets.cpu, "$1")
container:add(graph_container(cpu_load_widget, "CPU Load"))


--
-- GPU
--
if file.exists("/usr/bin/nvidia-smi") and not file.exists("/proc/acpi/bbswitch")then
    local gpu_temp_widget = awful.widget.watch(
        "nvidia-smi --format=csv,nounits,noheader --query-gpu=temperature.gpu",
        15,
        function(widget, stdout)
            temp_markup(widget, text.trim(stdout))
        end
    )
    container:add(gpu_temp_widget)
    awful.tooltip { objects = {gpu_temp_widget}, text = "GPU Temp" }

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
        make_graph()
    )
    container:add(graph_container(gpu_load_widget, "GPU Load"))
end


--
-- Memory usage
--
local mem_pct = wibox.widget.textbox()
local mem_graph = make_graph()
vicious.register(
    mem_pct, vicious.widgets.mem, string.format('<span color="%s">$1%%</span>', colors.background)
)
vicious.register(mem_graph, vicious.widgets.mem, "$1")
awful.tooltip { objects = {mem_pct}, text = "Memory Usage"}
container:add(mem_pct)
container:add(graph_container(mem_graph, "Memory Usage"))

return container
