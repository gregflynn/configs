local awful     = require('awful')
local beautiful = require('beautiful')
local gears     = require('gears')
local wibox     = require('wibox')

local lain = require('lain')

local FontIcon        = require('util/fonticon')
local SanityContainer = require('util/sanitycontainer')

local markup   = lain.util.markup


local fonticon = FontIcon()
local city_id = 4930956
local color = beautiful.colors.purple

-- https://openweathermap.org/weather-conditions
local icon_map = {
    ["01d"] = "\u{e30d}",
    ["01n"] = "\u{e32b}",
    ["02d"] = "\u{e302}",
    ["02n"] = "\u{e37e}",
    ["03d"] = "\u{e376}",
    ["03n"] = "\u{e377}",
    ["04d"] = "\u{e376}",
    ["04n"] = "\u{e377}",
    ["09d"] = "\u{e309}",
    ["09n"] = "\u{e334}",
    ["10d"] = "\u{e308}",
    ["10n"] = "\u{e333}",
    ["11d"] = "\u{e30f}",
    ["11n"] = "\u{e338}",
    ["13d"] = "\u{e30a}",
    ["13n"] = "\u{e335}",
    ["50d"] = "\u{e3ae}",
    ["50n"] = "\u{e35d}",
}

-- local tooltip = awful.tooltip {}

local weather = lain.widget.weather {
    city_id = city_id,
    units = 'imperial',
    showpopup = 'off',
    settings = function()
        local current_temp = math.floor(weather_now["main"]["temp"])
        local humidity = math.floor(weather_now["main"]["humidity"])
        local icon_id = weather_now["weather"][1]["icon"]
        local description = weather_now["weather"][1]["description"]

        widget:set_markup(markup.fg.color(color, string.format('%d°F', current_temp)))
        container:set_tooltip_color(string.format('%s%% humidity and %s', humidity, description))
        fonticon:update(icon_map[icon_id], color)

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

container = SanityContainer {
    widget = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        fonticon,
        weather.widget
    },
    color = color,
    buttons = gears.table.join(
        awful.button({ }, 1, function()
            weather.show(5)
        end),
        awful.button({ }, 3, function()
            awful.spawn("xdg-open https://openweathermap.org/city/"..city_id)
        end)
    )
}

return container
