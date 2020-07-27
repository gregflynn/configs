local os, string, table = os, string, table

local gears     = require('gears')
local glib      = require('lgi')
local Container = require('sanity/util/container')
local display   = require('sanity/util/display')
local text      = require('sanity/util/text')

local DateTime  = glib.GLib.DateTime
local TimeZone  = glib.GLib.TimeZone

local spawn   = require('awful.spawn')
local markup  = require('lain.util.markup')
local textbox = require('wibox.widget.textbox')
local fixed   = require('wibox.layout.fixed')
local widget  = require('wibox.widget')

-- http://man7.org/linux/man-pages/man3/strptime.3.html
local time_fmt = '%I:%M'
local week_fmt = '%a'
local date_fmt = '%m/%d'
local refresh  = 60

local text_color = colors.blue

local space     = ' '
local newline   = '\n'
local empty_str = ''

local function calc_timeout()
    return refresh - os.time() % refresh
end

local time_text  = textbox()
local week_text  = textbox()
local date_text  = textbox()

function strip_leading_zero(s)
    return s:gsub('^0', empty_str, 1)
end

local clock_container = Container {
    widget = widget {
        layout = fixed.vertical,
        display.center(week_text),
        display.center(time_text),
        display.center(date_text),
    },
    color = text_color,
}

local day_of_month_fmt = '%d'
local cal_command      = 'cal | tail -n +2'
local cal_table        = {}

local timer
function clock_update()
    local now = DateTime.new_now(TimeZone.new_local())

    time_text:set_markup(markup.fg.color(text_color, strip_leading_zero(now:format(time_fmt))))
    week_text:set_markup(markup.fg.color(text_color, now:format(week_fmt)))
    date_text:set_markup(markup.fg.color(text_color, strip_leading_zero(now:format(date_fmt))))

    spawn.easy_async_with_shell(cal_command, function(stdout)
        local cal_table_idx = 1
        local split_stdout = text.split(text.trim_end(stdout), newline)

        for i=1, #split_stdout do
            cal_table[cal_table_idx]   = newline
            cal_table[cal_table_idx+1] = space
            cal_table[cal_table_idx+2] = split_stdout[i]
            cal_table[cal_table_idx+3] = space
            cal_table_idx = cal_table_idx + 4
        end

        local padded_cal = table.concat(cal_table, empty_str, 1, cal_table_idx-1)
        local dom_str = string.format(' %s ', strip_leading_zero(now:format(day_of_month_fmt)))

        padded_cal = padded_cal:gsub(
            dom_str,
            markup.fg.color(text_color, dom_str)
        )

        clock_container:set_tooltip_color(
            ' Time &amp; Date ',
            string.format(
                '%s\n%s',
                now:format(' %I:%M %p %Z (%z) \n %A %B %d '),
                padded_cal
            )
        )
    end)
    timer.timeout = calc_timeout()
    return true
end
timer = gears.timer.weak_start_new(refresh, clock_update)
timer:emit_signal('timeout')

return clock_container
