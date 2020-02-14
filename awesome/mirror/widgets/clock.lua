local awful     = require('awful')
local beautiful = require('beautiful')
local gears     = require('gears')
local glib      = require('lgi')
local wibox     = require('wibox')

local lain = require('lain')

local FontIcon        = require('util/fonticon')
local SanityContainer = require('util/sanitycontainer')

local DateTime  = glib.GLib.DateTime
local TimeZone  = glib.GLib.TimeZone
local markup    = lain.util.markup


-- http://man7.org/linux/man-pages/man3/strptime.3.html
local calendar = 'https://calendar.google.com/'
local clock_fmt = '%I:%M %a %m/%d'
local tooltip_fmt = '%A %B %d'
local refresh = 60
local text_color = beautiful.colors.blue

local function calc_timeout()
    return refresh - os.time() % refresh
end

local clock_icon = FontIcon()
local clock = wibox.widget.textbox()
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
    ['12'] = '\u{e381}'
}

local awesome_menu = {
    {'Reload', function()
        os.execute("pkill redshift")
        awesome.restart()
    end}
}
local system_menu = {
    {'Sleep', 'systemctl suspend'},
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

clock_container = SanityContainer {
    widget = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        clock_icon,
        clock
    },
    color = text_color,
    buttons = gears.table.join(
        awful.button({ }, 1, function() menu:toggle() end),
        awful.button({ }, 3, function()
            awful.spawn({'xdg-open', calendar})
        end)
    )
}

local timer
function clock_update()
    local now = DateTime.new_now(TimeZone.new_local())
    local icon = clock_map[now:format('%I')]
    clock_icon:update(icon, text_color)
    clock:set_markup(markup.fg.color(text_color, now:format(clock_fmt)))
    clock_container:set_tooltip_color('Time / Date', now:format(tooltip_fmt))
    timer.timeout = calc_timeout()
    timer:again()
    return true
end
timer = gears.timer.weak_start_new(refresh, clock_update)
timer:emit_signal('timeout')

return clock_container
