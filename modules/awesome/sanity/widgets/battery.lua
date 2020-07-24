local string = string

local bat = require('lain.widget.bat')

local Pie        = require('sanity/util/pie')
local DoubleWide = require('sanity/util/doublewide')
local FontIcon   = require('sanity/util/fonticon')
local Container  = require('sanity/util/container')

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
    [battery_state_plug]    = colors.green,
    [battery_state_full]    = colors.green,
    [battery_state_good]    = colors.green,
    [battery_state_low]     = colors.orange,
    [battery_state_caution] = colors.red,
    [battery_state_empty]   = colors.red,
}

local battery = {
    battery_enabled = false,
    font_icon       = FontIcon {small = true},
    pie             = Pie {
        color     = battery_colors.plug,
        icon      = battery_icons.plug,
        max_value = 100,
    }
}

battery.container = Container {
    widget = DoubleWide {
        left_widget  = battery.font_icon,
        right_widget = battery.pie,
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
        battery.container.visible = false
    else
        battery.container.visible = true
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

    battery.container:set_color(color)
    battery.container:set_tooltip_color(
        ' Battery ',
        string.format(
            ' %s%% \n %s%s ',
            bat_now.perc,
            time or empty_str,
            status or empty_str
        ),
        color
    )

    battery.pie:update(bat_now.perc, color)
    battery.font_icon:update(battery_icons[bs], color)
end

battery.lain_widget = bat {
    settings    = battery_update,
    timeout     = 5,
    full_notify = 'off',
}

return battery.container
