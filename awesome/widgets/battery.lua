local lain = require("lain")
local beautiful = require("beautiful")
local battery_enabled = true

local battery = lain.widget.bat {
    battery_enabled = true
}

function battery.settings()
    if bat_now.perc == "N/A" then
        battery.battery_enabled = false
        return
    else
        battery.battery_enabled = true
    end

    local color = beautiful.fg_focus
    local icon = "🔌"

    if bat_now.status == "Discharging" then
        color = beautiful.fg_urgent
        icon = "🔋"
    end

    widget:set_markup(string.format('<span color="%s">%s %s%%</span>', color, icon, bat_now.perc))
end

return battery
