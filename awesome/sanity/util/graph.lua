local beautiful = require('beautiful')

local margin     = require('wibox.container.margin')
local graph      = require('wibox.widget.graph')
local background = require('wibox.container.background')

local fg_color     = colors.gray
local bg_color     = colors.background
local border_shape = beautiful.border_shape

local graph_border = 2

function factory(args)
    local args = args or {}

    local color  = args.color or fg_color
    local height = args.height or 20
    local scale  = args.scale or false

    local g = graph {
        height = height,
    }

    -- NOTE: these are set like this because they don't work in the constructor
    g.color = color
    g.background_color = bg_color
    g.scale = scale

    local graph_margin = margin(g, graph_border, graph_border, graph_border, graph_border)
    local b = background(graph_margin, bg_color, border_shape)
    b.shape_border_width = graph_border
    b.shape_border_color = color
    g.container = margin(b, 5, 4, 3, 3)

    return g
end

return factory
