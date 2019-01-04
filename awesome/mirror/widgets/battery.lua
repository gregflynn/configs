local awful     = require("awful")
local beautiful = require("beautiful")
local lain      = require("lain")
local wibox     = require("wibox")

local FontIcon = require("util/fonticon")

local colors = beautiful.colors
local dpi    = beautiful.xresources.apply_dpi


local battery_icons = {
    plug    = "\u{f1e6}",
    full    = "\u{f240}",
    good    = "\u{f241}",
    low     = "\u{f242}",
    caution = "\u{f243}",
    empty   = "\u{f244}",
}

local battery_colors = {
    plug    = colors.background,
    full    = colors.background,
    good    = colors.background,
    low     = colors.background,
    caution = colors.white,
    empty   = colors.red,
}

local battery = {
    battery_enabled = false,
    font_icon = FontIcon(),
    tooltip = awful.tooltip {}
}

function battery:get_status()
    local pct = bat_now.perc or 0

    if bat_now.ac_status == "1" and (bat_now.status == "Charging" or bat_now.status == "Full") then
        return "plug"
    end

    if     pct < 10 then return "empty"
    elseif pct < 20 then return "caution"
    elseif pct < 50 then return "low"
    elseif pct < 90 then return "good"
    end

    return "full"
end

battery.lain_widget = lain.widget.bat {
    settings = function()
        if bat_now.perc == "N/A" then
            battery.font_icon:update(battery_icons["empty"], colors.gray)
            widget:set_markup(string.format("<span color='%s'>N/A</span>", colors.gray))
            return
        end

        if bat_now.status == "Full" then
            battery.tooltip.text = "Full"
        elseif bat_now.status == "Charging" then
            battery.tooltip.text = bat_now.time.." Until Full"
        elseif bat_now.status == "Discharging" then
            battery.tooltip.text = bat_now.time.." Until Empty"
        else
            battery.tooltip.text = "N/A"
        end

        local status = battery:get_status()
        local color = battery_colors[status]
        battery.font_icon:update(battery_icons[status], color)
        widget:set_markup(string.format(
            '<span color="%s">%s%%</span>', color, bat_now.perc
        ))
    end
}

local container = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    battery.font_icon,
    wibox.container.margin(battery.lain_widget.widget, dpi(0), dpi(3))
}
battery.tooltip:add_to_object(container)

return container
