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

local battery = {
    battery_enabled = false,
}

function battery.get_status()
    local pct = bat_now.perc or 0
    local bt_status = bat_now.status
    local ac_status = bat_now.ac_status

    if ac_status == "1" and (bt_status == "Charging" or bt_status == "Full") then
        return "plug"
    end

    if     pct < 5  then return "empty"
    elseif pct < 20 then return "caution"
    elseif pct < 50 then return "low"
    elseif pct < 90 then return "good"
    end

    return "full"
end

battery.font_icon = FontIcon {}

battery.lain_widget = lain.widget.bat {
    settings = function()
        if bat_now.perc == "N/A" then
            battery.battery_enabled = false
            return
        else
            battery.battery_enabled = true
        end

        local status = battery:get_status()
        local font_icon = battery_icons[status]
        local color = colors.green
        if status == "low" then
            color = colors.yellow
        elseif status == "empty" or status == "caution" then
            color = colors.red
        end

        battery.font_icon:update(font_icon, color)

        widget:set_markup(
            string.format(
                '<span color="%s">%s%%</span>',
                color,
                bat_now.perc
            )
        )
    end
}

-- so the outside world doesn't need to know how weird the internal
-- structure of this widget is
battery.widget = battery.lain_widget.widget

if battery.battery_enabled then
    battery.container = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        wibox.container.margin(battery.font_icon, dpi(0), dpi(3)),
        wibox.container.margin(battery.widget,    dpi(0), dpi(3))
    }
else
    battery.container = nil
end


return battery
