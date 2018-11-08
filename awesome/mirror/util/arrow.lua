local wibox     = require("wibox")
local beautiful = require("beautiful")
local lain      = require("lain")

local colors = beautiful.colors
local dpi    = beautiful.xresources.apply_dpi
local sep    = lain.util.separators


local default_color = colors.background

local function factory(args)
    local widget     = args.widget
    local color      = args.color or default_color
    local is_right   = args.right or false
    local to_color   = args.to_color or default_color
    local from_color = args.from_color or default_color
    local in_list    = args.list or false
    local no_left    = args.no_left or false
    local no_right   = args.no_right or false

    local left
    if not is_right and not no_left then
        -- normal left-ward to-side
        left = sep.arrow_left(to_color, color)
    elseif not in_list and not no_left then
        -- normal right-ward from-side, except in list mode
        left = sep.arrow_right(from_color, color)
    end

    local right
    if is_right and not no_right then
        -- normal right-ward to-side
        right = sep.arrow_right(color, to_color)
    elseif not in_list and not no_right then
        -- normal left-ward from-side, except in list mode
        right = sep.arrow_left(color, from_color)
    end

    local arrow = wibox.layout.fixed.horizontal()
    local background = wibox.container.background(
        wibox.container.margin(
            widget, dpi(5), dpi(5), beautiful.bar_margin, beautiful.bar_margin
        ),
        color
    )

    arrow.widget = widget
    if left then
        arrow:add(left)
    end

    if widget then
        arrow:add(background)
    end

    if right then
        arrow:add(right)
    end

    function arrow:update(color, to_color, from_color)
        background.bg = color
        if left then
            local col1 = is_right and from_color or to_color
            left.update(col1 or default_color, color)
        end

        if right then
            local col2 = is_right and to_color or from_color
            right.update(color, col2 or default_color)
        end
    end

    return arrow
end

return factory
