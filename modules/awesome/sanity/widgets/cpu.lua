local math, string = math, string

local vicious   = require('vicious')
local Container = require('sanity/util/container')
local Graph     = require('sanity/util/graph')
local display   = require('sanity/util/display')

local watch  = require('awful.widget.watch')
local markup = require('lain.util.markup')
local widget = require('wibox.widget')
local fixed  = require('wibox.layout.fixed')

local color  = colors.red

local cpu_container
local cpu_load_widget = Graph {color = color}

local cpu_temp_widget = watch('sensors', 5, function(w, stdout)
    local temp = stdout:match('Package id 0:%s+%p(%d+%p%d)')
    if not temp then
        temp = stdout:match('Tdie:%s+%p(%d+%p%d)')
    end

    if not temp then
        temp = '??'
    end

    w:set_markup(markup.fg.color(color, string.format('%s°C', math.floor(temp))))
end)

vicious.register(cpu_load_widget, vicious.widgets.cpu, '$1', graph_interval)

cpu_container = Container {
    widget = widget {
        layout = fixed.vertical,
        display.center(cpu_temp_widget),
        cpu_load_widget.container,
    },
    color = color,
}
cpu_container:set_tooltip_color(' Processor ')

return cpu_container
