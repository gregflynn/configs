local awful     = require('awful')
local wibox     = require('wibox')
local beautiful = require('beautiful')

local lain = require('lain')

local colors = beautiful.colors
local dpi    = beautiful.xresources.apply_dpi
local markup = lain.util.markup


function factory(args)
    local widget   = args.widget
    local is_right = not args.left
    local color    = args.color or colors.white
    local tooltip  = args.tooltip or ''
    local buttons  = args.buttons

    local left = 0
    local right = 0
    if is_right then
        right = beautiful.widget_space
    else
        left = beautiful.widget_space
    end

    local ln = wibox.container.background(wibox.widget.base.make_widget(), color)
    ln.forced_height = beautiful.widget_under

    local widget_container = wibox.container.margin(widget, dpi(2), dpi(2), dpi(2), dpi(1))
    local vertical = wibox.layout.align.vertical(nil, widget_container, ln)
    local SanityContainer = wibox.container.margin(vertical, left, right)

    --
    -- Color
    --
    function SanityContainer:set_color(color)
        ln.bg = color
    end

    --
    -- Tooltips
    --
    SanityContainer.tooltip = awful.tooltip {
        objects = {SanityContainer},
        text = tooltip
    }

    function SanityContainer:set_tooltip(text)
        SanityContainer.tooltip.text = text
    end

    function SanityContainer:set_markup(markup)
        SanityContainer.tooltip:set_markup(markup)
    end

    function SanityContainer:set_tooltip_color(text)
        SanityContainer:set_markup(markup.fg.color(color, text))
    end

    --
    -- Buttons
    --
    if buttons then
        SanityContainer:buttons(buttons)
    end

    return SanityContainer
end

return factory
