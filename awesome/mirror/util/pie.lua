local beautiful = require('beautiful')
local wibox     = require('wibox')

local colors = beautiful.colors
local dpi    = beautiful.xresources.apply_dpi


function factory(args)
    local args = args or {}

    local bg_color             = args.bg_color or colors.background
    local pie_color            = args.color or colors.blue
    local thickness            = args.thickness or 8
    local max_value            = args.max_value or 1

    local pie_widget = wibox.widget {
        max_value = max_value,
        thickness = dpi(thickness),
        start_angle = (2 * math.pi) * 3 / 4,
        bg = bg_color,
        border_color = pie_color,
        border_width = dpi(2),
        colors = {colors.black},
        widget = wibox.container.arcchart
    }
    local p = 2
    local pie_container = wibox.container.margin(pie_widget, dpi(p), dpi(p), dpi(p), dpi(p))

    function pie_container:update(value)
        pie_widget.values = {value}
    end

    return pie_container
end

return factory
