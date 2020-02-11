local awful     = require("awful")
local beautiful = require("beautiful")

local rofi = {}

local function rofi_show(show)
    awful.spawn("rofi -show "..show.." -scroll-method 1 -matching normal")
end

local function rofi_script(script_name)
    awful.spawn({"python3", beautiful.dotsan_home.."/rofi/"..script_name})
end

--
-- Program launcher mode for Rofi
--
function rofi:run()
    rofi_show("drun -drun-show-actions")
end

--
-- Password manager frontend
--
function rofi:pass()
    awful.spawn("rofi-pass")
end

--
-- Rofi Calculator
--
function rofi:calc()
    rofi_show("calc -modi calc -no-show-match -no-sort")
end

--
-- Tag Windows Switcher
--
function rofi:tagwindows()
    rofi_show("windowcd")
end

--
-- All Windows Switcher
--
function rofi:allwindows()
    rofi_show("window")
end

--
-- Emoji Picker
--
function rofi:emoji()
    awful.spawn("rofimoji")
end

--
-- Web Search
--
function rofi:websearch()
    rofi_script("rofi_search.py")
end

--
-- Project Manager
--
function rofi:projects()
    rofi_script("rofi_project.py")
end

function rofi:network()
    rofi_script("rofi_network.py")
end

function rofi:vpn()
    awful.spawn({"bash", beautiful.dotsan_home.."/rofi/rofi_vpn.sh"})
end

return rofi
