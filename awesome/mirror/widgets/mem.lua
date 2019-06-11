local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local lain = require('lain')

local text            = require('util/text')
local number          = require('util/number')
local FontIcon        = require('util/fonticon')
local SanityContainer = require('util/sanitycontainer')

local dpi    = beautiful.xresources.apply_dpi
local markup = lain.util.markup


local color = beautiful.colors.yellow
local mem_icon = FontIcon {icon = '\u{f85a}', color = color}
local mem_pct = wibox.widget.textbox()

local container = SanityContainer {
    widget = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        mem_icon,
        mem_pct
    },
    tooltip = 'Memory Used',
    color = color
}

awful.widget.watch(
    {awful.util.shell, '-c', "free -b | grep Mem | awk '{print $2,$3}'"},
    5,
    function(widget, stdout)
        local split = text.split(stdout)
        local total_bytes = tonumber(split[1])
        local used_bytes = tonumber(split[2])
        local used_raw_pct = used_bytes / total_bytes
        local pct_used = number.round(used_raw_pct * 100, 0)

        mem_pct:set_markup(markup.fg.color(color, string.format('%s%%', pct_used)))
        container:set_tooltip_color(string.format(
            '%s / %s',
            number.human_bytes(used_bytes),
            number.human_bytes(total_bytes)
        ))
    end
)

return container
