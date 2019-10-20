local awful     = require("awful")
local beautiful = require("beautiful")

local rofi = {}

local function rofi_show(show)
    awful.spawn("rofi -show "..show.." -scroll-method 1 -matching normal")
end

--
-- Program launcher mode for Rofi
--
function rofi:run()
    rofi_show("drun")
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
    awful.spawn({ "python3", beautiful.dotsan_home.."/rofi/rofi_search.py" })
end

return rofi
