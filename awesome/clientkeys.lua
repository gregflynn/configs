local gears = require("gears")
local awful = require("awful")


clientkeys = gears.table.join(
    awful.key(
        { modkey,        }, "f",
        function(c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "Fullscreen", group = "client"}
    ),
    awful.key(
        { modkey,        }, "q",
        function(c)
            c:kill()
        end,
        {description = "Quit", group = "client"}
    ),
    awful.key(
        { modkey,        }, "c",
        function(c)
            awful.placement.centered(c)
            c.maximized_vertical = false
            c.maximized_horizontal = false
        end,
        {description = "Center client", group = "client"}
    ),
    awful.key(
        { modkey, "Shift" }, "f",
        function(c)
            c.floating = not c.floating
            c.maximized_vertical = false
            c.maximized_horizontal = false
        end,
        {description = "Toggle Floating", group = "client"}
    ),
    awful.key(
        { modkey, shift  }, "m",
        function(c)
            c:swap(awful.client.getmaster())
        end,
        {description = "Move Window to Master", group = "client"}
    ),
    awful.key(
        { modkey,        }, "t",
        function(c)
            c.ontop = not c.ontop
        end,
        {description = "Keep Windows on Top", group = "client"}
    ),
    awful.key(
        { modkey,        }, "n",
        function(c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end,
        {description = "Minimize Window", group = "client"}
    ),
    awful.key(
        { modkey,        }, "m",
        function(c)
            c.maximized_vertical = false
            c.maximized_horizontal = false
            if not c.maximized then
                awful.titlebar.hide(c)
            elseif c.floating then
                awful.titlebar.show(c)
            end
            c.maximized = not c.maximized
            c:raise()
        end,
        {description = "Maximize Window", group = "client"}
    )
)

return clientkeys
