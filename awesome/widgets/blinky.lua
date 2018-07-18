local awful     = require("awful")
local beautiful = require("beautiful")
local wibox     = require("wibox")
local gears     = require("gears")
local dpi       = beautiful.xresources.apply_dpi

local command = "blinky"
local enabled_icon = "/usr/share/icons/elementary/places/48/user-bookmarks.svg"
local disabled_icon = "/usr/share/icons/elementary/places/48/bookmark-missing.svg"

local blinky = wibox.widget {
    blinky_installed = false,
    image   = enabled_icon,
    resize  = true,
    widget  = wibox.widget.imagebox,
    enabled = true,
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

blinky.container = {
    layout = wibox.layout.fixed.horizontal,
    wibox.container.margin(blinky, dpi(0), dpi(3)),
}

-- check if blinky is installed on this computer and set the initial state
awful.spawn.easy_async({command, "--status"}, function(stdout)
    local trimmed_output = stdout:match("^%s*(.-)%s*$")
    if trimmed_output == "#000000" then
        -- leds are disabled
        blinky.enabled = true
        blinky:toggle()
    elseif trimmed_output:sub(1, 1) == "#" then
        -- leds are enabled
        blink.enabled = false
        blinky:toggle()
    else
        -- blinky isn't installed on this machine
        blinky.container = nil
    end
end)

return blinky
