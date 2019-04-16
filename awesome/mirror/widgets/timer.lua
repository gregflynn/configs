local awful     = require("awful")
local beautiful = require("beautiful")
local gears     = require("gears")
local naughty   = require("naughty")
local wibox     = require("wibox")

local lain = require("lain")

local FontIcon = require("util/fonticon")

local colors = beautiful.colors
local markup = lain.util.markup


local Timer = {
    container = wibox.layout.fixed.horizontal(),
    icon      = FontIcon { icon = "\u{fa1a}", color = colors.background },
    progress  = wibox.widget.textbox(),
    menu      = awful.menu(),
    menu_show = false,
    paused    = false,
    seconds   = 0,
    interval  = 10,
}

local function update_progress()
    Timer.seconds = Timer.seconds - Timer.interval

    local value, unit

    if Timer.seconds < 60 then -- seconds
        value = Timer.seconds
        unit = 's'
    elseif Timer.seconds < 60 * 60 then -- minutes
        value = math.floor(Timer.seconds / 60)
        unit = 'm'
    else
        local total_minutes = math.floor(Timer.seconds / 60)
        local hours = math.floor(total_minutes / 60)
        local minutes = total_minutes % 60
        value = string.format('%s:%s', hours, minutes)
        unit = ''
    end

    Timer.progress:set_markup(markup.fg.color(colors.background, string.format(
            '%s%s', value, unit
    )))

end

local function start_timer(duration_seconds)
    Timer.menu_show = false
    if Timer.timer.started then Timer.timer:stop() end
    Timer.seconds = duration_seconds
    Timer.timer:start()
    update_progress()
    Timer.container:reset()
    Timer.container:add(Timer.progress)
end

local function complete_timer()
    Timer.seconds = 0
    Timer.timer:stop()
    Timer.container:reset()
    Timer.container:add(Timer.icon)
end

Timer.timer = gears.timer {
    timeout = Timer.interval,
    callback = function()
        if Timer.seconds - Timer.interval <= 0 then
            complete_timer()
            naughty.notify({
                title = 'Timer Complete',
                timeout = 30,
                text = 'Stopped Timer'
            })
        else
            update_progress()
        end
    end
}

-- Menu Options
Timer.menu:add({ '1m', function() start_timer(60) end})
Timer.menu:add({ '2m', function() start_timer(120) end})
Timer.menu:add({ '5m', function() start_timer(300) end})
Timer.menu:add({ '10m', function() start_timer(600) end})
Timer.menu:add({ '15m', function() start_timer(900) end})
Timer.menu:add({ '20m', function() start_timer(1200) end})
Timer.menu:add({ '30m', function() start_timer(1800) end})
Timer.menu:add({ '1h', function() start_timer(60 * 60) end})
Timer.menu:add({ '1h 30m', function() start_timer(60 * 60 * 1.5) end})
Timer.menu:add({ '2h', function() start_timer(60 * 60 * 2) end})
Timer.menu:add({ '3h', function() start_timer(60 * 60 * 3) end})
Timer.menu:add({ '4h', function() start_timer(60 * 60 * 4) end})
Timer.menu:add({ '6h', function() start_timer(60 * 60 * 6) end})
Timer.menu:add({ '8h', function() start_timer(60 * 60 * 8) end})
Timer.menu:add({ '12h', function() start_timer(60 * 60 * 12) end})


-- Buttons
Timer.container:buttons(gears.table.join(
    awful.button({}, 1, function()
        if Timer.menu_show then
            -- close
            Timer.menu:hide()
            Timer.menu_show = false
        else
            -- open
            Timer.menu:show()
            Timer.menu_show = true
        end
    end),
    awful.button({}, 2, function()
        if Timer.seconds > 0 then
            naughty.notify({ title = 'Timer Canceled' })
            complete_timer()
        end
    end),
    awful.button({}, 3, function()
        if Timer.seconds > 0 then
            if Timer.paused then
                Timer.timer:start()
                Timer.paused = false
                naughty.notify({ title = 'Timer Resumed' })
            else
                Timer.timer:stop()
                Timer.paused = true
                naughty.notify({ title = 'Timer Paused' })
            end
        end
    end)
))

Timer.container:add(Timer.icon)
return Timer.container
