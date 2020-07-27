local tonumber = tonumber

local Container = require('sanity/util/container')
local Graph     = require('sanity/util/graph')
local display   = require('sanity/util/display')
local file      = require('sanity/util/file')
local text      = require('sanity/util/text')

local watch  = require('awful.widget.watch')
local markup = require('lain.util.markup')
local widget = require('wibox.widget')
local fixed  = require('wibox.layout.fixed')

local color   = colors.green
local visible = false

if file.exists('/usr/bin/nvidia-smi') and not file.exists('/proc/acpi/bbswitch') then
    visible = true
    local gpu_graph = Graph {color = color}
    local gpu_temp = watch(
        'nvidia-smi --format=csv,nounits,noheader --query-gpu=temperature.gpu,utilization.gpu',
        graph_interval,
        function(w, stdout)
            local split_stdout = text.split(stdout, ', ')
            local temp = text.trim(split_stdout[1])
            local load = text.trim(split_stdout[2])

            w:set_markup(markup.fg.color(color, temp..'°C'))
            gpu_graph:add_value(tonumber(load) / 100.0)
        end
    )
end

local gpu_container = Container {
    color = color,
    widget = visible and widget {
        layout = fixed.vertical,
        gpu_graph.container,
        display.center(gpu_temp)
    } or nil,
    no_tooltip = true
}

gpu_container.visible = visible

return gpu_container
