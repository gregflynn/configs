local math, string = math, string

local vicious   = require('vicious')
local Container = require('sanity/util/container')
local Graph     = require('sanity/util/graph')
local display   = require('sanity/util/display')
local text      = require('sanity/util/text')

local spawn  = require('awful.spawn')
local watch  = require('awful.widget.watch')
local markup = require('lain.util.markup')
local widget = require('wibox.widget')
local fixed  = require('wibox.layout.fixed')

local color  = colors.red

local cpu_container
local cpu_load_widget = Graph {color = color}

local cpu_cmd = 'top -b -n 1 -o %CPU | tail -n +7 | head -n 6 | awk \'{$1="";$2="";$3="";$4="";$5="";$6="";$7="";$8="";$10="";$11=""; print $0 }\''

local newline           = '\n'
local space             = ' '
local tooltip_lines     = {}

local cpu_temp_widget = watch('sensors', 5, function(w, stdout)
    local temp = stdout:match('Package id 0:%s+%p(%d+%p%d)')
    if not temp then
        temp = stdout:match('Tdie:%s+%p(%d+%p%d)')
    end

    if not temp then
        temp = '??'
    end

    w:set_markup(markup.fg.color(color, string.format('%s°C', math.floor(temp))))

    spawn.easy_async_with_shell(cpu_cmd, function(s)
        local lines     = text.split(s, newline)
        local top_index = 1

        for i=1, #lines do
            if i == #lines then
                -- last line is empty
                break
            end

            if i > 1 then
                tooltip_lines[top_index] = newline
                top_index = top_index + 1
            end

            tooltip_lines[top_index] = space
            if i == 1 then
                tooltip_lines[top_index+1] = markup.fg.color(color, text.trim(lines[i]))
            else
                tooltip_lines[top_index+1] = text.trim(lines[i])
            end
            tooltip_lines[top_index+2] = space
            top_index = top_index + 3
        end

        local top = table.concat(tooltip_lines, '', 1, top_index-1)
        cpu_container:set_tooltip_color(' Processor ', top)
    end)
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

return cpu_container
