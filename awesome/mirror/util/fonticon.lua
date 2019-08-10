local beautiful = require("beautiful")
local wibox     = require("wibox")

local dpi = beautiful.xresources.apply_dpi


local fonticon_font = "Hack Nerd Font Mono 20"
local margin_h = dpi(4)
local margin_v = dpi(2)

function factory(args)
    local args = args or {}

    local icon  = args.icon or "X"
    local color = args.color

    local FontIcon = wibox.widget.textbox()

    function FontIcon:update(icon, color)
        local prefix = string.format(
            "<span font='%s'%s>", fonticon_font,
            color and string.format(" color='%s'", color) or ""
        )
        local suffix = "</span>"
        FontIcon:set_markup(prefix..icon..suffix)
    end

    FontIcon:update(icon, color)

    local container = wibox.container.margin(
        FontIcon, margin_h, margin_h, margin_v, margin_v
    )

    function container:update(icon, color)
        FontIcon:update(icon, color)
    end

    container.font_icon = FontIcon
    return container
end


return factory
