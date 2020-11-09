local arcchart = require('wibox.container.arcchart')
local margin   = require('wibox.container.margin')
local widget   = require('wibox.widget')

local default_fg_color = colors.blue
local default_bg_color = colors.background

function factory(args)
    local args = args or {}

    local bg_color  = args.bg_color or default_bg_color
    local pie_color = args.color or default_fg_color
    local max_value = args.max_value or 1

    local pie_widget = widget {
        max_value    = max_value,
        thickness    = 20,
        start_angle  = (2 * math.pi) * 3 / 4,
        bg           = bg_color,
        border_color = pie_color,
        colors       = {pie_color},
        widget       = arcchart,
        values       = {0}
    }
    pie_widget:set_children({icon_widget})

    local pie_container = margin(pie_widget, 2, 2, 5, 5)

    function pie_container:update(value, color)
        local v = pie_widget.values
        v[1] = value
        -- setting the values again triggers a re-render
        pie_widget.values = v
        pie_widget.colors[1] = color or pie_color
    end

    function pie_container:update_icon(icon, color)
        if icon then
            icon_widget:update(icon, color)
            icon_widget.visible = true
        else
            icon_widget.visible = false
        end
    end

    return pie_container
end

return factory
