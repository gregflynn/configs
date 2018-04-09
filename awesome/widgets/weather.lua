local awful     = require("awful")
local lain      = require("lain")
local beautiful = require("beautiful")
local wibox     = require("wibox")
local gears     = require("gears")

local dpi       = beautiful.xresources.apply_dpi

local humidity_bar = wibox.widget {
    max_value        = 100,
    widget           = wibox.widget.progressbar,
    color            = beautiful.colors.blue,
    background_color = beautiful.colors.grey
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
    showpopup = 'off',
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
            day, beautiful.colors.red, tmax, beautiful.colors.blue, tmin, desc
        )
    end
}

weather.container = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    wibox.container.margin(weather.icon, dpi(0), dpi(3)),
    wibox.container.margin(weather.widget, dpi(0), dpi(0)),
    -- wibox.container.margin(rotated_humidity, dpi(0), dpi(10)),
    buttons = gears.table.join(
        awful.button({ }, 1, function()
            weather.show(5)
        end)
    )
}

return weather
