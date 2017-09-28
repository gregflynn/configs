local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")

local brightness = {
    bright_notification = nil
}

function brightness.update()
    awful.spawn.easy_async("light", function(stdout, stderr, reason, exit_code)
        local level = tonumber(stdout)
        local preset = {
            title = "Brightness",
            text = level
        }

        local int = math.modf((level / 100) * awful.screen.focused().mywibox.height)
        preset.text = string.format(
            "[%s%s]",
            string.rep("|", int),
            string.rep(" ", awful.screen.focused().mywibox.height - int)
        )

        if not bright_notification then
            bright_notification = naughty.notify {
                preset  = preset,
                destroy = function() bright_notification = nil end
            }
        else
            naughty.replace_text(bright_notification, preset.title, preset.text)
        end
    end)
end

brightness.globalkeys = gears.table.join(
    awful.key({ }, "XF86MonBrightnessDown", function ()
        awful.spawn("light -U -p 10")
        brightness.update()
    end),
    awful.key({ }, "XF86MonBrightnessUp", function ()
        awful.spawn("light -A -p 10")
        brightness.update()
    end)
)

return brightness
