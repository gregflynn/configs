local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")

local brightness = {
    width = 30,
    bright_notification = nil
}

local tick = "█"
local tick_pre = "\u{e0b2}"
local tick_post = "\u{e0b0}"
local tick_none = " "
local step_amount = "10"

local function brightness_update()
    awful.spawn.easy_async("light", function(stdout)
        local preset = {
            position = "bottom_middle",
            title    = "brightness",
            font     = beautiful.font_notif
        }

        local level = math.modf((tonumber(stdout) / 100) * brightness.width)
        preset.text = string.format(
            "%s%s%s%s",
            tick_pre,
            string.rep(tick, level),
            string.rep(tick_none, brightness.width - level),
            tick_post
        )

        if not brightness.bright_notification then
            brightness.bright_notification = naughty.notify {
                preset  = preset,
                destroy = function() brightness.bright_notification = nil end
            }
        else
            naughty.replace_text(brightness.bright_notification, preset.title, preset.text)
        end
    end)
end

function brightness:up()
    awful.spawn.easy_async("light -U "..step_amount, function()
        brightness_update()
    end)
end

function brightness:down()
    awful.spawn.easy_async("light -A "..step_amount, function()
        brightness_update()
    end)
end

return brightness
