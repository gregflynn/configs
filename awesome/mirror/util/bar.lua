local wibox     = require("wibox")
local beautiful = require("beautiful")
local lain      = require("lain")

local dpi       = beautiful.xresources.apply_dpi
local sep       = lain.util.separators


local bar = {}

function bar.margin(widget, left, right)
    return wibox.container.margin(
        widget, dpi(left or 0), dpi(right or 0), beautiful.bar_margin, beautiful.bar_margin
    )
end

-- Create a single left-ward block
function bar.arrow_left_block(widget, fg, bg)
    return {
        layout = wibox.layout.align.horizontal,
        sep.arrow_left(fg, bg),
        wibox.container.background(bar.margin(widget, 5, 5), bg)
    }
end

-- Create a single right-ward block
function bar.arrow_right_block(widget, fg, bg)
    return {
        layout = wibox.layout.align.horizontal,
        wibox.container.background(bar.margin(widget, 5, 5), bg),
        sep.arrow_right(fg, bg)
    }
end

-- Internal method for created a list of blocks connected together
function bar.arrow_list(blocks, direction)
    local container = {layout = wibox.layout.fixed.horizontal}
    local last_color
    local block_fn = bar.arrow_left_block
    if direction == "right" then
        block_fn = bar.arrow_right_block
    end

    for i, block in ipairs(blocks) do
        container[i] = block_fn(
            block.widget,
            last_color or beautiful.colors.background,
            block.color
        )
        last_color = block.color
    end

    return container
end

function bar.arrow_left_list(blocks)
    return bar.arrow_list(blocks, "left")
end

function bar.arrow_right_list(blocks)
    return bar.arrow_list(blocks, "right")
end


return bar
