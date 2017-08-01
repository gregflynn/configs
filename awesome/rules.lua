local awful = require("awful")

awful.rules.rules = {
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
            border_width = 2
        }
    },
    {
        rule = { name = "Albert" },
        properties = {
            placement = function (c)
                awful.placement.centered(c, { offset = { y = -350 } })
            end,
            border_width = 0,
            floating = true
        }
    },
    {
        rule = { instance = "tilix", type = "normal" },
        properties = {
            border_width = 0,
            floating = false
        }
    },
    {
        rule = { instance = "code", type = "normal"  },
        properties = {
            border_width = 0,
            floating = false
        }
    }
}
