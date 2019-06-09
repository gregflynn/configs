local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi
local colors = beautiful.colors


function factory(args)
    local arg = args or {}

    local width = args.width or dpi(25)
    local tooltip_text = args.tooltip_text or ''
    
    local graph = wibox.widget.graph {
        width = width,
    }

    graph.background_color = colors.background
    if args.color then
        graph.color = args.color
    end

    if args.stack_colors then
        graph.stack_colors = args.stack_colors
        graph.stack = true
    end

    graph.container = wibox.container.margin(graph, dpi(2), dpi(2), dpi(4), dpi(4))
    graph.tooltip = awful.tooltip { objects = {graph.container}, text = tooltip_text }

    return graph
end

return factory
