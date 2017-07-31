local lain      = require("lain")
local beautiful = require("beautiful")

local battery = {
    battery_enabled = false
}

battery.lain_widget = lain.widget.bat {
    settings = function()
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
}

-- so the outside world doesn't need to know how weird the internal
-- structure of this widget is
battery.widget = battery.lain_widget.widget

return battery
