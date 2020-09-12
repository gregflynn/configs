local math, string = math, string

local Container = require('sanity/util/container')
local display   = require('sanity/util/display')

local watch  = require('awful.widget.watch')
local markup = require('lain.util.markup')

local color  = colors.red

local cpu_container

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


cpu_container = Container {
    widget = display.center(cpu_temp_widget),
    color = color,
    no_tooltip = true,
}

return cpu_container
