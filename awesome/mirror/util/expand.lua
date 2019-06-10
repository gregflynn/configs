local awful     = require("awful")
local beautiful = require("beautiful")
local gears     = require("gears")
local wibox     = require("wibox")

local FontIcon = require("util/fonticon")

local colors = beautiful.colors


local function factory(args)
    local args = args or {}
    local expanded_widget = args.widget
    local icon_name = args.font_icon

    local Expand = FontIcon()
    local container = wibox.layout.fixed.horizontal()

    -- initializing this to true in order for below toggle before return
    -- will run the on-close code
    local open = true

    function Expand:set_state(is_open)
        open = is_open
    end

    function Expand:toggle()
        container:reset()

        if open then
            open = false
            Expand:update(icon_name, colors.yellow)
        else
            open = true
            Expand:update("\u{f659}", colors.red)
            container:add(expanded_widget)
        end

        container:add(Expand)
    end

    Expand:buttons(gears.table.join(
        awful.button({}, 1, function() Expand:toggle() end),
        awful.button({}, 3, function() Expand:toggle() end)
    ))
    Expand:toggle()

    return container
end

return factory
