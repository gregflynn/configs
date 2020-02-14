local awful     = require('awful')
local wibox     = require('wibox')
local beautiful = require('beautiful')

local lain = require('lain')

local colors = beautiful.colors
local dpi    = beautiful.xresources.apply_dpi
local markup = lain.util.markup


function factory(args)
    local widget     = args.widget
    local is_right   = not args.left
    local color      = args.color or colors.white
    local tooltip    = args.tooltip or ''
    local buttons    = args.buttons
    local globalkeys = args.globalkeys
    local no_tooltip = args.no_tooltip

    local left = 0
    local right = 0
    if is_right then
        right = beautiful.widget_space
    else
        left = beautiful.widget_space
    end

    local ln = wibox.container.background(wibox.widget.base.make_widget(), color)
    ln.forced_height = beautiful.widget_under

    local widget_container = wibox.container.margin(widget, dpi(2), dpi(2), dpi(0), dpi(0))
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
    if not no_tooltip then
        SanityContainer.tooltip = awful.tooltip {
            objects = {SanityContainer},
        }

        function SanityContainer:set_tooltip(text)
            SanityContainer.tooltip.text = text
        end

        function SanityContainer:set_markup(markup)
            SanityContainer.tooltip:set_markup(markup)
        end

        function SanityContainer:set_tooltip_color(title, text)
            local body = markup.big(title)
            if text then
                body = string.format('%s \n\n%s', body, text)
            end
            SanityContainer:set_markup(markup.fg.color(color, body))
        end

        SanityContainer:set_tooltip_color(tooltip)
    end

    --
    -- Buttons
    --
    if buttons then
        SanityContainer:buttons(buttons)
    end

    if args.globalkeys then
        SanityContainer.globalkeys = globalkeys
    end

    --
    -- Visibility
    --
    function SanityContainer:toggle()
        SanityContainer.visible = not SanityContainer.visible
    end

    function SanityContainer:show()
        SanityContainer.visible = true
    end

    function SanityContainer:hide()
        SanityContainer.visible = false
    end

    return SanityContainer
end

return factory
