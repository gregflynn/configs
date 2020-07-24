local tonumber = tonumber

local spawn  = require('awful.spawn')

local Container  = require('sanity/util/container')
local DoubleWide = require('sanity/util/doublewide')
local FontIcon   = require('sanity/util/fonticon')
local Pie        = require('sanity/util/pie')
local text       = require('sanity/util/text')
local timer      = require('sanity/util/timer')

local color   = colors.yellow
local mem_pie = Pie {color = color}

local memory_container = Container {
    widget = DoubleWide {
        left_widget = FontIcon {icon = '', color = color, small = true},
        right_widget = mem_pie,
    },
    color = color,
    no_tooltip = true,
}

local mem_cmd = 'free -b | grep Mem | awk \'{print $2,$3}\''

timer.loop(5, function()
    spawn.easy_async_with_shell(mem_cmd, function(mem_stdout)
        local split = text.split(mem_stdout)
        local total_bytes = tonumber(split[1])
        local used_bytes = tonumber(split[2])
        local used_raw_pct = used_bytes / total_bytes

        mem_pie:update(used_raw_pct)
    end)
end)

return memory_container
