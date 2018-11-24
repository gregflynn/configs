local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")

local brightness = {
    width = 30,
    bright_notification = nil
}

function brightness.update()
    awful.spawn.easy_async("light", function(stdout)
        local preset = {
            position = "bottom_middle",
            title    = "Brightness",
        }

        local level = math.modf((tonumber(stdout) / 100) * brightness.width)
        preset.text = string.format(
            "[%s%s]",
            string.rep("|", level),
            string.rep(" ", brightness.width - level)
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

brightness.globalkeys = gears.table.join(
    awful.key(
        { }, "XF86MonBrightnessDown",
        function()
            awful.spawn("light -U -p 10")
            brightness.update()
        end
    ),
    awful.key(
        { }, "XF86MonBrightnessUp",
        function()
            awful.spawn("light -A -p 10")
            brightness.update()
        end
    )
)

return brightness
