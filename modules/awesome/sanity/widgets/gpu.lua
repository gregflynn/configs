local Container = require('sanity/util/container')
local display   = require('sanity/util/display')
local file      = require('sanity/util/file')
local text      = require('sanity/util/text')

local watch  = require('awful.widget.watch')
local markup = require('lain.util.markup')

local color   = colors.green
local visible = false
local gpu_container

if file.exists('/usr/bin/nvidia-smi') and not file.exists('/proc/acpi/bbswitch') then
    visible = true
    local gpu_temp = watch(
        'nvidia-smi --format=csv,nounits,noheader --query-gpu=temperature.gpu,utilization.gpu',
        graph_interval,
        function(w, stdout)
            local split_stdout = text.split(stdout, ', ')
            local temp = text.trim(split_stdout[1])

            w:set_markup(markup.fg.color(color, temp..'°C'))
        end
    )
    gpu_container = Container {
        color = color,
        widget = visible and display.center(gpu_temp) or nil,
        no_tooltip = true
    }
else
    gpu_container = Container {}
end


gpu_container.visible = visible

return gpu_container
