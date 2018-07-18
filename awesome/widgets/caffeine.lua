local awful     = require("awful")
local beautiful = require("beautiful")
local wibox     = require("wibox")
local gears     = require("gears")
local dpi       = beautiful.xresources.apply_dpi

local command = "xautolock"
local enabled_icon = "/usr/share/icons/elementary/status/48/locked.svg"
local disabled_icon = "/usr/share/icons/elementary/status/48/dialog-error.svg"

-- make sure xuatolock is enabled when being loaded
awful.spawn({command, "-enable"})

local caffeine = wibox.widget {
    image   = enabled_icon,
    resize  = true,
    widget  = wibox.widget.imagebox,
    enabled = true,
}

function caffeine.toggle()
    if caffeine.enabled then
        caffeine.image = disabled_icon
        awful.spawn({command, "-disable"})
    else
        caffeine.image = enabled_icon
        awful.spawn({command, "-enable"})
    end
    caffeine.enabled = not caffeine.enabled
end

caffeine:buttons(gears.table.join(
    awful.button({}, 1, function()
        caffeine:toggle()
    end),
    awful.button({}, 3, function()
        caffeine:toggle()
    end)
))

caffeine.container = {
    layout = wibox.layout.fixed.horizontal,
    wibox.container.margin(caffeine, dpi(0), dpi(3)),
}

return caffeine
