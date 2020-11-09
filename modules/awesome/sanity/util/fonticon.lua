local beautiful = require('beautiful')

local margin  = require('wibox.container.margin')
local textbox = require('wibox.widget.textbox')

local default_color = colors.white

local font_name    = beautiful.font_name
local default_icon = ''
local icon_fmt     = '<span font="%s %d" color="%s">%s</span>'

function factory(args)
    local args = args or {}

    local icon     = args.icon or default_icon
    local color    = args.color or default_color
    local size     = args.size or 20
    local margin_l = args.margin_l or 2
    local margin_r = args.margin_r or 2
    local margin_t = args.margin_t or 0
    local margin_b = args.margin_b or 0

    local FontIcon            = textbox()
    local font_icon_container = margin(FontIcon, margin_l, margin_r, margin_t, margin_b)

    function FontIcon:update(i, c)
        FontIcon:set_markup(string.format(icon_fmt, font_name, size, c or color, i))
    end

    function font_icon_container:update(i, c)
        FontIcon:update(i, c)
    end

    FontIcon:update(icon, color)
    font_icon_container.font_icon = FontIcon
    return font_icon_container
end

return factory
