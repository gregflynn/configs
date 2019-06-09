local awful     = require("awful")
local beautiful = require("beautiful")
local gears     = require("gears")
local wibox     = require("wibox")
local lain      = require("lain")
local glib      = require("lgi").GLib

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

local clock = wibox.widget.textbox()
local tooltip = awful.tooltip {objects = {clock}}

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
local function clock_update()
    local now = DateTime.new_now(TimeZone.new_local())
    clock:set_markup(markup.fg.color(text_color, now:format(clock_fmt)))
    tooltip:set_markup(now:format(tooltip_fmt))
    timer.timeout = calc_timeout()
    timer:again()
    return true
end
timer = gears.timer.weak_start_new(refresh, clock_update)
timer:emit_signal('timeout')


clock:buttons(gears.table.join(
    awful.button({ }, 1, function() menu:toggle() end),
    awful.button({ }, 3, function()
        awful.spawn("xdg-open "..calendar)
    end)
))


return clock
