local lain      = require("lain")
local beautiful = require("beautiful")
local wibox     = require("wibox")
local dpi       = beautiful.xresources.apply_dpi

local humidity_bar = wibox.widget {
    max_value        = 100,
    widget           = wibox.widget.progressbar,
    color            = beautiful.fg_minimize,
    background_color = beautiful.fg_normal
}

local rotated_humidity = wibox.widget {
    humidity_bar,
    forced_width = dpi(5),
    direction    = 'east',
    layout       = wibox.container.rotate
}

local weather = lain.widget.weather {
    city_id = 4930956,
    units = 'imperial',
    settings = function()
        current_temp = math.floor(weather_now["main"]["temp"])
        current_humidity = math.floor(weather_now["main"]["humidity"])
        humidity_bar:set_value(current_humidity)
        widget:set_markup(string.format('%d°F', current_temp))
    end,
    notification_text_fun = function(wn)
        local day = os.date("%a %d", wn["dt"])
        local tmin = math.floor(wn["temp"]["min"])
        local tmax = math.floor(wn["temp"]["max"])
        local desc = wn["weather"][1]["description"]

        return string.format(
            '<b>%s</b>: <span color="%s">%d</span>/<span color="%s">%d</span> %s',
            day, beautiful.fg_urgent, tmax, beautiful.fg_minimize, tmin, desc
        )
    end
}

weather.container = {
    layout = wibox.layout.fixed.horizontal,
    wibox.container.margin(weather.icon,     dpi(0),  dpi(3), dpi(4), dpi(4)),
    wibox.container.margin(weather.widget,   dpi(0),  dpi(3), dpi(4), dpi(4)),
    wibox.container.margin(rotated_humidity, dpi(0), dpi(10), dpi(6), dpi(6))
}

return weather
