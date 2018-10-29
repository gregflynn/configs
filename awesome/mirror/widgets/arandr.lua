local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful")

local Dropdown = require("util/dropdown")
local file     = require("util/file")


local arandr_folder = beautiful.home.."/.screenlayout/"

local arandr = Dropdown {
    folder = arandr_folder,
    font_icon = "\u{f879}",
    right_click = "arandr",
    tooltip_text = "Monitor Configs",
    menu_func = function(full_path)
        awful.spawn(string.format("bash %s", full_path))
    end
}

if file.exists(arandr_folder) then
    arandr.container = wibox.widget {
        layout = wibox.layout.fixed.horizontal, arandr
    }
else
    arandr.container = nil
end

return arandr
