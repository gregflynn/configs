local os, string, table = os, string, table

local gears     = require('gears')
local glib      = require('lgi')
local Container = require('sanity/util/container')
local text      = require('sanity/util/text')

local DateTime  = glib.GLib.DateTime
local TimeZone  = glib.GLib.TimeZone

local spawn   = require('awful.spawn')
local markup  = require('lain.util.markup')
local textbox = require('wibox.widget.textbox')

-- http://man7.org/linux/man-pages/man3/strptime.3.html
local date_fmt = '%a %m/%d %I:%M'
local refresh  = 60

local text_color = colors.background

local function calc_timeout()
    return refresh - os.time() % refresh
end

local date_text = textbox()

function strip_leading_zero(s)
    return s:gsub('^0', '', 1)
end

local clock_container = Container {
    widget = date_text,
    color = text_color,
}

local cal_table = {}

local timer
function clock_update()
    local now = DateTime.new_now(TimeZone.new_local())

    date_text:set_markup(markup.fg.color(text_color, strip_leading_zero(now:format(date_fmt))))

    spawn.easy_async_with_shell('cal | tail -n +2', function(stdout)
        local cal_table_idx = 1
        local split_stdout = text.split(text.trim_end(stdout), '\n')

        for i=1, #split_stdout do
            cal_table[cal_table_idx]   = '\n'
            cal_table[cal_table_idx+1] = ' '
            cal_table[cal_table_idx+2] = split_stdout[i]
            cal_table[cal_table_idx+3] = ' '
            cal_table_idx = cal_table_idx + 4
        end

        local padded_cal = table.concat(cal_table, '', 1, cal_table_idx-1)
        local dom_str = string.format(' %s ', strip_leading_zero(now:format('%d')))

        padded_cal = padded_cal:gsub(
            dom_str,
            markup.fg.color(colors.blue, dom_str)
        )

        clock_container:set_markup(
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
