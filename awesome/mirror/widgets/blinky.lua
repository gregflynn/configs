local awful     = require("awful")
local beautiful = require("beautiful")
local wibox     = require("wibox")
local gears     = require("gears")
local dpi       = beautiful.xresources.apply_dpi

local command = "blinky"
local enabled_icon = "/usr/share/icons/elementary/places/48/user-bookmarks.svg"
local disabled_icon = "/usr/share/icons/elementary/places/48/bookmark-missing.svg"

-- shameless
-- https://stackoverflow.com/questions/1340230/check-if-directory-exists-in-lua/21637668#21637668
function exists(name)
    if type(name)~="string" then return false end
    return os.rename(name,name) and true or false
end

-- disable LEDs to be in a consistent state
awful.spawn({command, "--off"})

local blinky = wibox.widget {
    image   = disabled_icon,
    resize  = true,
    widget  = wibox.widget.imagebox,
    enabled = false,
}

function blinky.toggle()
    if blinky.enabled then
        blinky.image = disabled_icon
        awful.spawn({command, "--off"})
    else
        blinky.image = enabled_icon
        awful.spawn({command, "--on"})
    end
    blinky.enabled = not blinky.enabled
end

blinky:buttons(gears.table.join(
    awful.button({}, 1, function()
        blinky:toggle()
    end),
    awful.button({}, 3, function()
        blinky:toggle()
    end)
))

if exists("/usr/bin/blinky") then
    blinky.container = {
        layout = wibox.layout.fixed.horizontal,
        wibox.container.margin(blinky, dpi(0), dpi(3)),
    }
else
    blinky.container = nil
end

return blinky
