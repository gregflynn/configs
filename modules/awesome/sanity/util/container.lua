local string = string

local beautiful = require('beautiful')

local tooltip    = require('awful.tooltip')
local markup     = require('lain.util.markup')
local background = require('wibox.container.background')
local margin     = require('wibox.container.margin')
local align      = require('wibox.layout.align')
local base       = require('wibox.widget.base')

local line_widget  = base.make_widget()
local widget_space = beautiful.widget_space
local widget_line  = beautiful.widget_line

local default_color = colors.white
local tooltip_fmt   = '%s \n\n%s'

function factory(args)
    local widget     = args.widget
    local color      = args.color or default_color
    local tt_text    = args.tooltip or ''
    local buttons    = args.buttons
    local no_tooltip = args.no_tooltip or false

    local ln = background(line_widget, color)
    ln.forced_height = widget_line

    local Container = margin(align.vertical(nil, margin(widget, 2, 2), ln), widget_space, widget_space)

    --
    -- Color
    --
    function Container:set_color(c)
        ln.bg = c
    end

    --
    -- Tooltips
    --
    if not no_tooltip then
        Container.tooltip = tooltip {objects = {Container}}

        function Container:set_tooltip(text)
            Container.tooltip.text = text
        end

        function Container:set_markup(m)
            Container.tooltip:set_markup(m)
        end

        function Container:set_tooltip_color(title, text, c)
            local body
            local clr  = c or color

            if text then
                body = string.format(
                    tooltip_fmt, markup.fg.color(clr, markup.big(title)), markup.fg.color(default_color, text)
                )
            else
                body = markup.fg.color(clr, markup.big(title))
            end

            Container:set_markup(body)
        end

        Container:set_tooltip_color(tt_text)
    end

    --
    -- Buttons
    --
    if buttons then
        Container:buttons(buttons)
    end

    --
    -- Visibility
    --
    function Container:toggle()
        Container.visible = not Container.visible
    end

    function Container:show()
        Container.visible = true
    end

    function Container:hide()
        Container.visible = false
    end

    return Container
end

return factory
