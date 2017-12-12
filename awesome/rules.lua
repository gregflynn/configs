local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

return {
    {
        rule = { },
        properties = {
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.centered,
            titlebars_enabled = true,
            maximized_vertical = false,
            maximized_horizontal = false,
            maximized = false,
            floating = true,
            border_width = dpi(1)
        }
    },
    {
        rule = { instance = "xfce4-terminal", type = "normal" },
        properties = {
            floating = false
        }
    },
    {
        rule = { instance = "code", type = "normal"  },
        properties = {
            floating = false
        }
    }
}
