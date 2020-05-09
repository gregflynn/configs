local string, tonumber = string, tonumber

local Container = require('sanity/util/container')
local Pie       = require('sanity/util/pie')
local text      = require('sanity/util/text')
local number    = require('sanity/util/number')
local timer     = require('sanity/util/timer')

local spawn  = require('awful.spawn')

local color   = colors.yellow
local mem_pie = Pie {color = color, icon = ''}

local memory_container = Container {
    widget  = mem_pie,
    tooltip = ' Memory Used ',
    color   = color
}

local mem_cmd = 'free -b | grep Mem | awk \'{print $2,$3}\''

timer.loop(5, function()
    spawn.easy_async_with_shell(mem_cmd, function(mem_stdout)
        local split = text.split(mem_stdout)
        local total_bytes = tonumber(split[1])
        local used_bytes = tonumber(split[2])
        local used_raw_pct = used_bytes / total_bytes
        local pct_used = number.round(used_raw_pct * 100, 0)

        mem_pie:update(used_raw_pct)

        memory_container:set_tooltip_color(' Memory ', string.format(
            ' %s%% Used \n %sB/%sB',
            pct_used,
            number.human_bytes(used_bytes, 2),
            number.human_bytes(total_bytes, 2)
        ))
    end)
end)

return memory_container
