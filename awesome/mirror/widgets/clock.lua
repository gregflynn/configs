local awful     = require("awful")
local beautiful = require("beautiful")
local gears     = require("gears")
local wibox     = require("wibox")
local lain      = require("lain")
local glib      = require("lgi").GLib

local FontIcon = require('util/fonticon')

local DateTime  = glib.DateTime
local TimeZone  = glib.TimeZone
local markup    = lain.util.markup

local calendar = 'https://calendar.google.com/'
local clock_fmt = '%H:%M '
local tooltip_fmt = '%A %m/%d'
local refresh = 60
local text_color = beautiful.colors.blue

local function calc_timeout()
    return refresh - os.time() % refresh
end

local clock_icon = FontIcon()
local clock = wibox.widget.textbox()
local tooltip = awful.tooltip {}
local clock_map = {
    ['01'] = '\u{e382}',
    ['02'] = '\u{e383}',
    ['03'] = '\u{e384}',
    ['04'] = '\u{e385}',
    ['05'] = '\u{e386}',
    ['06'] = '\u{e387}',
    ['07'] = '\u{e388}',
    ['08'] = '\u{e389}',
    ['09'] = '\u{e38a}',
    ['10'] = '\u{e38b}',
    ['11'] = '\u{e38c}',
    ['12'] = '\u{e38d}'
}

local awesome_menu = {
    {'Reload', function()
        os.execute("pkill redshift")
        awesome.restart()
    end}
}
local system_menu = {
    {'Reboot', 'reboot'},
    {'Shutdown', 'shutdown -h now'}
}
local menu = awful.menu({
    theme = { width = 120 },
    items = {
        {'Calendar', function()
            awful.spawn({'xdg-open', calendar})
        end},
        {'Awesome WM', awesome_menu, beautiful.awesome_icon},
        {'System', system_menu}
    }
})

local timer
function clock_update()
    local now = DateTime.new_now(TimeZone.new_local())
    local icon = clock_map[now:format('%I')]
    clock_icon:update(icon, text_color)
    clock:set_markup(markup.fg.color(text_color, now:format(clock_fmt)))
    tooltip:set_markup(now:format(tooltip_fmt))
    timer.timeout = calc_timeout()
    timer:again()
    return true
end
timer = gears.timer.weak_start_new(refresh, clock_update)
timer:emit_signal('timeout')

local container = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    clock_icon,
    clock,
    buttons = gears.table.join(
        awful.button({ }, 1, function() menu:toggle() end),
        awful.button({ }, 3, function()
            awful.spawn("xdg-open "..calendar)
        end)
    )
}
tooltip:add_to_object(container)

return container
