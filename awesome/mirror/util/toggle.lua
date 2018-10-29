local awful = require("awful")
local gears = require("gears")

local FontIcon = require("util/fonticon")


local function factory(args)
    local Toggle = FontIcon {}

    function Toggle.enable()
        Toggle:update(args.font_icon_enabled, args.font_icon_enabled_color)
        awful.spawn(args.command_enable)
    end

    function Toggle.disable()
        Toggle:update(args.font_icon_disabled, args.font_icon_disabled_color)
        awful.spawn(args.command_disable)
    end

    function Toggle:toggle()
        if Toggle.enabled then
            Toggle:disable()
        else
            Toggle:enable()
        end
        Toggle.enabled = not Toggle.enabled
    end

    Toggle:buttons(gears.table.join(
        awful.button({}, 1, function()
            Toggle:toggle()
        end),
        awful.button({}, 3, function()
            Toggle:toggle()
        end)
    ))

    if args.default_enabled then
        Toggle.enabled = true
        Toggle:enable()
    else
        Toggle.enabled = false
        Toggle:disable()
    end

    return Toggle
end

return factory
