local wibox     = require('wibox')
local beautiful = require('beautiful')

local colors = beautiful.colors
local dpi    = beautiful.xresources.apply_dpi


function factory(args)
    local widget = args.widget
    local is_right = not args.left
    local color = args.color or colors.white

    local left = 0
    local right = 0
    if is_right then
        right = beautiful.widget_space
    else
        left = beautiful.widget_space
    end

    -- make the colored line
    local ln = wibox.container.background(wibox.widget.base.make_widget(), color)
    ln.forced_height = beautiful.widget_under

    local widget_container = wibox.container.margin(widget, dpi(2), dpi(2), dpi(2), dpi(1))
    local vertical = wibox.layout.align.vertical(nil, widget_container, ln)
    local SanityContainer = wibox.container.margin(vertical, left, right)

    function SanityContainer:set_color(color)
        ln.bg = color
    end

    return SanityContainer
end

return factory
