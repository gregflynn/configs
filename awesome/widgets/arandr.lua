local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local dropdown  = require("widgets/dropdown")
local dpi       = beautiful.xresources.apply_dpi


local arandr = dropdown {
    folder = os.getenv("HOME").."/.screenlayout/",
    icon = "/usr/share/icons/elementary/devices/48/video-display.svg",
    menu_func = function()
        awful.spawn(string.format("bash %s", full_path))
    end
}

arandr.container = {
    layout = wibox.layout.fixed.horizontal,
    wibox.container.margin(arandr, dpi(0), dpi(3), dpi(4), dpi(4)),
}

return arandr
