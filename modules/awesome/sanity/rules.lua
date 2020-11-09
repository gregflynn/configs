local awful     = require('awful')
local beautiful = require('beautiful')
local gears     = require('gears')

local function floating_rule(class)
    return {
        rule = { class = class },
        properties = { floating = true }
    }
end

local minimize_instead_of_kill = {
    'Slack'
}

local client_keys = gears.table.join(
    create_mod_key(shift, 'f', 'client', 'Fullscreen', function(c)
        c.fullscreen = not c.fullscreen
        c:raise()
    end),
    create_key('q', 'client', 'Quit', function(c)
        for _, class in ipairs(minimize_instead_of_kill) do
            if c.class == class then
                c.minimized = true
                return
            end
        end
        c:kill()
    end),
    create_mod_key(shift, 'c', 'client', 'Center client', function(c)
        if not c.maximized then
            awful.placement.centered(c)
            c.maximized_vertical = false
            c.maximized_horizontal = false
        end
    end),
    create_key('f', 'client', 'Toggle Floating', function(c)
        c.floating = not c.floating
        c.maximized_vertical = false
        c.maximized_horizontal = false
    end),
    create_key('t', 'client', 'Keep client on top', function(c)
        c.ontop = not c.ontop
    end),
    create_key('n', 'client', 'Minimize client', function(c)
        c.minimized = true
    end),
    create_key('m', 'client', 'Maximize client', function(c)
        c.maximized_vertical = false
        c.maximized_horizontal = false
        if not c.maximized then
            awful.titlebar.hide(c)
        elseif c.floating then
            awful.titlebar.show(c)
        end
        c.maximized = not c.maximized
        c:raise()
    end)
)

return {
    {
        rule = { },
        properties = {
            focus = awful.client.focus.filter,
            raise = true,
            keys = client_keys,
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
    floating_rule('File-roller'),
    floating_rule('Thunar')
}
