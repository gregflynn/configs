local math, os, string = math, os, string

local gears     = require('gears')
local Container = require('sanity/util/container')
local FontIcon  = require('sanity/util/fonticon')
local display   = require('sanity/util/display')
local icon      = require('sanity/util/icon')

local button  = require('awful.button')
local menu    = require('awful.menu')
local spawn   = require('awful.spawn')
local markup  = require('lain.util.markup')
local weather = require('lain.widget.weather')
local fixed   = require('wibox.layout.fixed')
local textbox = require('wibox.widget.textbox')
local widget  = require('wibox.widget')

local fonticon = FontIcon {large = true}
local city_id  = 4930956
local color    = colors.purple
local hi_color = colors.red
local lo_color = colors.blue

-- https://openweathermap.org/weather-conditions
local icon_map = {
    ['01d'] = '\u{e30d}',
    ['01n'] = '\u{e32b}',
    ['02d'] = '\u{e302}',
    ['02n'] = '\u{e37e}',
    ['03d'] = '\u{e376}',
    ['03n'] = '\u{e377}',
    ['04d'] = '\u{e376}',
    ['04n'] = '\u{e377}',
    ['09d'] = '\u{e309}',
    ['09n'] = '\u{e334}',
    ['10d'] = '\u{e308}',
    ['10n'] = '\u{e333}',
    ['11d'] = '\u{e30f}',
    ['11n'] = '\u{e338}',
    ['13d'] = '\u{e30a}',
    ['13n'] = '\u{e335}',
    ['50d'] = '\u{e3ae}',
    ['50n'] = '\u{e35d}',
}

function temp(value, type)
    local t = string.format('%d°F', value)
    if type == 'high' then
        return markup.fg.color(hi_color, t)
    elseif type == 'low' then
        return markup.fg.color(lo_color, t)
    else
        return t
    end
end

local weather_container
local weather_text = textbox()
local lain_weather = weather {
    city_id   = city_id,
    units     = 'imperial',
    showpopup = 'off',
    settings  = function()
        local current_temp = math.floor(weather_now['main']['temp'])
        local low_temp = math.floor(weather_now['main']['temp_min'])
        local high_temp = math.floor(weather_now['main']['temp_max'])
        local humidity = math.floor(weather_now['main']['humidity'])
        local icon_id = weather_now['weather'][1]['icon']
        local description = weather_now['weather'][1]['description']
        local wind_speed = weather_now['wind']['speed']

        weather_text:set_markup(markup.fg.color(color, temp(current_temp)))
        weather_container:set_tooltip_color(
            ' Weather',
            string.format(
                ' %d°F (%s/%s) \n %s mph wind \n %s%% humidity \n %s ',
                current_temp,
                temp(high_temp, 'high'),
                temp(low_temp, 'low'),
                wind_speed,
                humidity,
                description
            )
        )
        fonticon:update(icon_map[icon_id], color)

    end,
    notification_text_fun = function(wn)
        local day  = os.date('%a %d', wn['dt'])
        local tmin = math.floor(wn['temp']['min'])
        local tmax = math.floor(wn['temp']['max'])
        local desc = wn['weather'][1]['description']

        return string.format(
            '<b>%s</b>: %s/%s %s',
            day, temp(tmax, 'high'), temp(tmin, 'low'), desc
        )
    end
}

local weather_menu = menu({
    theme = { width = 200 },
    items = {
        {'Week Forecast', function()
            lain_weather.show(5)
        end, icon.get_path('status', 'weather-clear-symbolic', 'symbolic')},
        {'Radar', function()
            spawn('xdg-open https://darksky.net/forecast/42.3501,-71.0591/us12/en')
        end, icon.get_path('places', 'internet-radio-symbolic', 'symbolic')},
    }
})

weather_container = Container {
    widget = widget {
        layout = fixed.vertical,
        display.center(fonticon),
        display.center(weather_text),
    },
    color = color,
    buttons = gears.table.join(
        button({}, 1, function() weather_menu:toggle() end),
        button({}, 3, function() weather_menu:toggle() end)
    )
}

return weather_container
