local lain = require("lain")
local beautiful = require("beautiful")
local wibox = require("wibox")

local dpi = beautiful.xresources.apply_dpi

-- NOTE: only tested with elementary icon pack
local icon_fmt = "/usr/share/icons/elementary/status/48/battery-%s.svg"
local icon_chg_fmt = "/usr/share/icons/elementary/status/48/battery-%s-charging.svg"

local battery = {
    battery_enabled = false,
    icon = wibox.widget {
        image = string.format(icon_fmt, "full"),
        resize = true,
        widget = wibox.widget.imagebox
    },
    adapter = wibox.widget {
        image = string.format(icon_fmt, "ac-adapter"),
        resize = true,
        widget = wibox.widget.imagebox
    }
}

battery.lain_widget = lain.widget.bat {
    settings = function()
        if bat_now.perc == "N/A" then
            battery.battery_enabled = false
            return
        else
            battery.battery_enabled = true
        end

        local status = "full"
        if bat_now.perc < 5 then status = "empty"
        elseif bat_now.perc < 20 then status = "caution"
        elseif bat_now.perc < 50 then status = "low"
        elseif bat_now.perc < 90 then status = "good"
        end

        local color = beautiful.colors.green
        if bat_now.status == "Discharging" then
            color = beautiful.colors.red
            battery.adapter.visible = false
            battery.icon.image = string.format(icon_fmt, status)
        else
            if bat_now.status == "Charging" then
                battery.icon.image = string.format(icon_chg_fmt, status)
            else
                battery.icon.image = string.format(icon_fmt, "full-charged")
            end
            battery.adapter.visible = true
        end

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
    battery.container = {
        layout = wibox.layout.fixed.horizontal,
        wibox.container.margin(battery.adapter, dpi(0), dpi(0), dpi(4), dpi(4)),
        wibox.container.margin(battery.icon,    dpi(0), dpi(3), dpi(4), dpi(4)),
        wibox.container.margin(battery.widget,  dpi(0), dpi(10), dpi(4), dpi(4))
    }
else
    battery.container = nil
end

return battery
