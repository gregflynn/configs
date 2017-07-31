local lain      = require("lain")
local beautiful = require("beautiful")

local weather = lain.widget.weather {
    city_id = 4930956,
    units = 'imperial',
    settings = function()
        current_temp = math.floor(weather_now["main"]["temp"])
        current_humidity = math.floor(weather_now["main"]["humidity"])
        widget:set_markup(string.format('%d°F %d%%', current_temp, current_humidity))
    end,
    notification_text_fun = function(wn)
        local day = os.date("%a %d", wn["dt"])
        local tmin = math.floor(wn["temp"]["min"])
        local tmax = math.floor(wn["temp"]["max"])
        local desc = wn["weather"][1]["description"]

        return string.format(
        '<b>%s</b>: <span color="%s">%d</span>/<span color="%s">%d</span> %s',
        day, beautiful.fg_urgent, tmax, beautiful.fg_minimize, tmin, desc)
    end
}

return weather
