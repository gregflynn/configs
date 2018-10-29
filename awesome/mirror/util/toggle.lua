local awful = require("awful")
local gears = require("gears")

local FontIcon = require("util/fonticon")


local function factory(args)
    local new_toggle = FontIcon {}

    function new_toggle.enable()
        new_toggle:update(args.font_icon_enabled, args.font_icon_enabled_color)
        awful.spawn(args.command_enable)
    end

    function new_toggle.disable()
        new_toggle:update(args.font_icon_disabled, args.font_icon_disabled_color)
        awful.spawn(args.command_disable)
    end

    function new_toggle.toggle()
        if new_toggle.enabled then
            new_toggle:disable()
        else
            new_toggle:enable()
        end
        new_toggle.enabled = not new_toggle.enabled
    end

    new_toggle:buttons(gears.table.join(
        awful.button({}, 1, function()
            new_toggle:toggle()
        end),
        awful.button({}, 3, function()
            new_toggle:toggle()
        end)
    ))

    if args.default_enabled then
        new_toggle.enabled = true
        new_toggle:enable()
    else
        new_toggle.enabled = false
        new_toggle:disable()
    end

    return new_toggle
end

return factory
