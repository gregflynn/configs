local beautiful = require('beautiful')

local background = require('wibox.container.background')
local margin     = require('wibox.container.margin')
local base       = require('wibox.widget.base')

local ln = background(base.make_widget(), colors.gray)
ln.forced_height = beautiful.widget_line

local inlet = 8

function factory(args)
    local args = args or {}
    local is_bottom = args.bottom

    local top = 0
    local bottom = 0
    if is_bottom then
        bottom = beautiful.widget_space
    else
        top = beautiful.widget_space
    end

    return margin(ln, inlet, inlet, top, bottom)
end

return factory
