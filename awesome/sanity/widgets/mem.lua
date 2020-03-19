local string, tonumber = string, tonumber

local Container = require('sanity/util/container')
local Pie       = require('sanity/util/pie')
local text      = require('sanity/util/text')
local number    = require('sanity/util/number')
local timer     = require('sanity/util/timer')

local spawn  = require('awful.spawn')
local markup = require('lain.util.markup')

local color   = colors.yellow
local mem_pie = Pie {color = color, icon = ''}

local memory_container = Container {
    widget  = mem_pie,
    tooltip = ' Memory Used ',
    color   = color
}

local mem_cmd = 'free -b | grep Mem | awk \'{print $2,$3}\''
local top_cmd = 'top -b -n 1 -o %MEM | tail -n +7 | head -n 6 | awk \'{$1="";$2="";$3="";$4="";$5="";$6="";$7="";$8="";$9="";$11=""; print $0 }\''

local tooltip_lines = {}
local newline       = '\n'
local space         = ' '

timer.loop(5, function()
    spawn.easy_async_with_shell(mem_cmd, function(mem_stdout)
        local split = text.split(mem_stdout)
        local total_bytes = tonumber(split[1])
        local used_bytes = tonumber(split[2])
        local used_raw_pct = used_bytes / total_bytes
        local pct_used = number.round(used_raw_pct * 100, 0)

        mem_pie:update(used_raw_pct)

        spawn.easy_async_with_shell(top_cmd, function(top_stdout)
            local lines = text.split(top_stdout, newline)
            local index = 1

            for i=1, #lines do
                if i == #lines then
                    -- last line is empty
                    break
                end

                tooltip_lines[index] = newline
                tooltip_lines[index+1] = space
                if i == 1 then
                    tooltip_lines[index+2] = markup.fg.color(color, text.trim(lines[i]))
                else
                    tooltip_lines[index+2] = text.trim(lines[i])
                end
                tooltip_lines[index+3] = space
                index = index + 4
            end

            local top = table.concat(tooltip_lines, '', 1, index-1)
            memory_container:set_tooltip_color(' Memory ', string.format(
                ' %s%% Used \n %sB/%sB \n%s',
                pct_used,
                number.human_bytes(used_bytes, 2),
                number.human_bytes(total_bytes, 2),
                top
            ))
        end)
    end)
end)

return memory_container
