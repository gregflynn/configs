local awful = require("awful")
local gears = require("gears")

local FontIcon = require("util/fonticon")


local function factory(args)
    local args = args or {}

    local default_enabled          = args.default_enabled
    local tooltip_text             = args.tooltip_text
    local font_icon_enabled        = args.font_icon_enabled
    local font_icon_enabled_color  = args.font_icon_enabled_color
    local on_enable                = args.on_enable or function() end
    local font_icon_disabled       = args.font_icon_disabled
    local font_icon_disabled_color = args.font_icon_disabled_color
    local on_disable               = args.on_disable or function() end

    local Toggle = FontIcon()

    if tooltip_text then
        awful.tooltip {
            objects = {Toggle},
            text = tooltip_text
        }
    end

    function Toggle:enable()
        Toggle:update(font_icon_enabled, font_icon_enabled_color)
        on_enable()
    end

    function Toggle:disable()
        Toggle:update(font_icon_disabled, font_icon_disabled_color)
        on_disable()
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

    if default_enabled then
        Toggle.enabled = true
        Toggle:enable()
    else
        Toggle.enabled = false
        Toggle:disable()
    end

    return Toggle
end

return factory
