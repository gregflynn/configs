local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local dropdown  = require("widgets/dropdown")
local dpi       = beautiful.xresources.apply_dpi


-- shameless
-- https://stackoverflow.com/questions/1340230/check-if-directory-exists-in-lua/21637668#21637668
function exists(name)
    if type(name)~="string" then return false end
    return os.rename(name,name) and true or false
end

local arandr_folder = beautiful.home.."/.screenlayout/"

local arandr = dropdown {
    folder = arandr_folder,
    icon = "/usr/share/icons/elementary/devices/48/video-display.svg",
    right_click = "arandr",
    menu_func = function(full_path)
        awful.spawn(string.format("bash %s", full_path))
    end
}

if exists(arandr_folder) then
    arandr.container = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        wibox.container.margin(arandr, dpi(0), dpi(3)),
    }
else
    arandr.container = nil
end

return arandr
