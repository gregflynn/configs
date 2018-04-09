local awful     = require("awful")
local beautiful = require("beautiful")
local wibox     = require("wibox")
local gears     = require("gears")
local dpi       = beautiful.xresources.apply_dpi
local dropdown  = require("widgets/dropdown")

wallpapers_icon = dropdown {
    folder = os.getenv("HOME").."/Dropbox/Wallpapers",
    icon = "/usr/share/icons/elementary/apps/48/multimedia-photo-viewer.svg",
    menu_func = function(full_path)
        awful.screen.connect_for_each_screen(function(s)
            gears.wallpaper.maximized(full_path, s)
        end)
    end
}

wallpapers_icon.container = {
    layout = wibox.layout.fixed.horizontal,
    wibox.container.margin(wallpapers_icon, dpi(0), dpi(3)),
}

return wallpapers_icon
