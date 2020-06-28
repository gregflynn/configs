local awful     = require('awful')
local beautiful = require('beautiful')
local gears     = require('gears')

local function floating_rule(class)
    return {
        rule = { class = class },
        properties = { floating = true }
    }
end

return {
    {
        rule = { },
        properties = {
            focus = awful.client.focus.filter,
            raise = true,
            keys = require('sanity/clientkeys'),
            buttons = gears.table.join(
                awful.button({}, 1, function(c) client.focus = c; c:raise() end),
                awful.button({modkey}, 1, awful.mouse.client.move),
                awful.button({modkey}, 3, awful.mouse.client.resize)
            ),
            screen = awful.screen.preferred,
            placement = awful.placement.centered,
            titlebars_enabled = true,
            maximized_vertical = false,
            maximized_horizontal = false,
            maximized = false,
            border_color = beautiful.border_normal,
            border_width = beautiful.border_width,
            opacity = beautiful.normal_opacity,
            size_hints_honor = false
        }
    },
    floating_rule('Blueberry.py'),
    floating_rule('Pavucontrol'),
    floating_rule('pulse-sms'),
    floating_rule('Arandr'),
}
