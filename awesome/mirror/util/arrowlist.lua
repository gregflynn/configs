local wibox     = require("wibox")
local beautiful = require("beautiful")

local Arrow = require("util/arrow")

local colors = beautiful.colors
local capi = {
    screen = screen,
    awesome = awesome
}


local function should_display_on_primary(block, screen)
    if not block.primary_only or #capi.screen == 1 then
        return true
    end

    return capi.screen["primary"] == screen or capi.screen[1] == screen
end

local function factory(args)
    local blocks   = args.blocks or {}
    local prefix   = args.prefix or false
    local is_right = args.right or false
    local screen   = args.screen

    local container = {layout = wibox.layout.fixed.horizontal }
    local last_block

    for i, block in ipairs(blocks) do
        if should_display_on_primary(block, screen) then
            if is_right then
                if last_block then
                    container[i - 1] = Arrow {
                        widget   = last_block.widget,
                        color    = last_block.color,
                        right    = true,
                        to_color = block.color,
                        list     = not (prefix and i == 2)
                    }
                end
            else
                container[i] = Arrow {
                    widget   = block.widget,
                    color    = block.color,
                    to_color = last_block and last_block.color or colors.background,
                    list     = not (prefix and i == #blocks)
                }
            end

            last_block = block
        end
    end

    if is_right then
        container[#blocks] = Arrow {
            widget = last_block.widget,
            color  = last_block.color,
            right  = true,
            list   = not (prefix and i == 2)
        }
    end

    return container
end

return factory
