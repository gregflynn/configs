local string = string
local beautiful = require('beautiful')
local wibox = require('wibox')
local bat = require('lain.widget.bat')
local FontIcon   = require('sanity/util/fonticon')
local Container  = require('sanity/util/container')
local display   = require('sanity/util/display')

local battery_state_plug    = 'plug'
local battery_state_full    = 'full'
local battery_state_good    = 'good'
local battery_state_low     = 'low'
local battery_state_caution = 'caution'
local battery_state_empty   = 'empty'

local battery_icons = {
    [battery_state_plug]    = '\u{f1e6}',
    [battery_state_full]    = '\u{f240}',
    [battery_state_good]    = '\u{f241}',
    [battery_state_low]     = '\u{f242}',
    [battery_state_caution] = '\u{f243}',
    [battery_state_empty]   = '\u{f244}',
}

local battery_colors = {
    [battery_state_plug]    = colors.background,
    [battery_state_full]    = colors.background,
    [battery_state_good]    = colors.background,
    [battery_state_low]     = colors.orange,
    [battery_state_caution] = colors.red,
    [battery_state_empty]   = colors.red,
}

local bat_bar = wibox.widget {
    max_value        = 100,
    value            = 0,
    color            = colors.background,
    background_color = colors.gray,
    widget           = wibox.widget.progressbar,
    shape            = beautiful.border_shape,
}
local font_icon = FontIcon()
local battery_container = Container {
    widget = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        font_icon,
        display.vertical_bar(bat_bar),
    },
    color  = colors.yellow
}

local bat_perc_na         = 'N/A'
local bat_status_charging = 'Charging'
local bat_status_full     = 'Full'
local empty_str           = ''

function battery_update()
    local pct, time, status

    if bat_now.perc == bat_perc_na then
        pct = 0
    else
        pct = bat_now.perc
    end

    if bat_now.status == bat_status_charging then
        time = bat_now.time
        status = ' until full'
    elseif bat_now.status == 'Discharging' then
        time = bat_now.time
        status = ' left'
    else
        status = bat_now.status
    end

    if not status or status == bat_perc_na then
        battery_container.visible = false
    else
        battery_container.visible = true
    end

    local bs = battery_state_full
    if bat_now.ac_status == 1 and
            (bat_now.status == bat_status_charging or bat_now.status == bat_status_full) then
        bs = battery_state_plug
    end

    if     pct < 10 then bs = battery_state_empty
    elseif pct < 20 then bs = battery_state_caution
    elseif pct < 50 then bs = battery_state_low
    elseif pct < 90 then bs = battery_state_good
    end

    local color = battery_colors[bs]

    battery_container:set_color(color)
    battery_container:set_markup(
        string.format(
            ' %s%% \n %s%s ',
            bat_now.perc,
            time or empty_str,
            status or empty_str
        ),
        color
    )

    bat_bar:set_value(bat_now.perc)
    bat_bar.color = color
    font_icon:update(battery_icons[bs], color)
end

local lain_widget = bat {
    settings    = battery_update,
    timeout     = 5,
    full_notify = 'off',
}

return battery_container
