local margin     = require('wibox.container.margin')
local graph      = require('wibox.widget.graph')

local fg_color     = colors.gray
local bg_color     = colors.background

function factory(args)
    local args = args or {}

    local color  = args.color or fg_color
    local height = args.height or 18
    local scale  = args.scale or false

    local g = graph {
        height = height,
    }

    -- NOTE: these are set like this because they don't work in the constructor
    g.color = color
    g.background_color = bg_color
    g.scale = scale

    g.container = margin(g, 5, 5, 3, 3)

    return g
end

return factory
