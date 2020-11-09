local math, string, tonumber = math, string, tonumber

local beautiful = require('beautiful')
local naughty   = require('naughty')

local spawn = require('awful.spawn')

local easy_async = spawn.easy_async

local brightness = {
    width = 30,
    bright_notification = nil
}

local brightness_preset = {
    position = 'bottom_middle',
    title    = 'brightness',
    font     = beautiful.font_notif
}

local tick = '='
local tick_pre = '\u{e0b2}'
local tick_post = '\u{e0b0}'
local tick_none = ' '
local step_amount = '10'
local brightness_fmt = '%s%s%s%s'

local light_status = 'light'
local light_up     = 'light -A '..step_amount
local light_down   = 'light -U '..step_amount

local function brightness_update()
    easy_async(light_status, function(stdout)

        local level = math.modf((tonumber(stdout) / 100) * brightness.width)
        brightness_preset.text = string.format(
            brightness_fmt,
            tick_pre,
            string.rep(tick, level),
            string.rep(tick_none, brightness.width - level),
            tick_post
        )

        if not brightness.bright_notification then
            brightness.bright_notification = naughty.notify {
                preset  = brightness_preset,
                destroy = function()
                    brightness.bright_notification = nil
                end
            }
        else
            naughty.replace_text(
                brightness.bright_notification,
                brightness_preset.title,
                brightness_preset.text
            )
        end
    end)
end

function brightness:up()
    easy_async(light_up, brightness_update)
end

function brightness:down()
    easy_async(light_down, brightness_update)
end

return brightness
