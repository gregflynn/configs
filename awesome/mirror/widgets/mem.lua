local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local text            = require('util/text')
local number          = require('util/number')
local FontIcon        = require('util/fonticon')
local SanityContainer = require('util/sanitycontainer')
local Pie             = require('util/pie')

local color = beautiful.colors.yellow
local mem_icon = FontIcon {icon = '\u{f85a}', color = color}
local mem_pie = Pie {color = color}

local memory_container = SanityContainer {
    widget = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        mem_icon,
        mem_pie
    },
    tooltip = 'Memory Used',
    color = color
}

awful.widget.watch(
    {awful.util.shell, '-c', "free -b | grep Mem | awk '{print $2,$3}'"},
    5,
    function(_, stdout)
        local split = text.split(stdout)
        local total_bytes = tonumber(split[1])
        local used_bytes = tonumber(split[2])
        local used_raw_pct = used_bytes / total_bytes
        local pct_used = number.round(used_raw_pct * 100, 0)

        mem_pie:update(used_raw_pct)
        memory_container:set_tooltip_color('Memory', string.format(
            '%s%% Used\n%sB / %sB',
            pct_used,
            number.human_bytes(used_bytes, 2),
            number.human_bytes(total_bytes, 2)
        ))
    end
)

return memory_container
