local awful = require('awful')
local gears = require('gears')

local minimize_instead_of_kill = {
    'Slack'
}

clientkeys = gears.table.join(
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
        -- The client currently has the input focus, so it cannot be
        -- minimized, since minimized clients can't have the focus.
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
    end),
    create_mod_key(shift, 'j', 'client', 'Move client to next screen', function(c)
        c:move_to_screen()
    end),
    create_mod_key(shift, 'k', 'client', 'Move client to previous screen', function(c)
        c:move_to_screen(c.screen.index-1)
    end)
)

return clientkeys
