local awful     = require("awful")
local gears     = require("gears")


local rofi = {}

function rofi:show(method)
    local show = ""
    if method == "run" then
        show = "drun"
    elseif method == "ssh" then
        show = "ssh"
    elseif method == "calc" then
        show = "calc -modi calc -no-show-match -no-sort"
    elseif method == "windows" then
        show = "windowcd"
    elseif method == "allwindows" then
        show = "window"
    end

    awful.spawn("rofi -show "..show.." -scroll-method 1 -matching normal")
end

rofi.globalkeys = gears.table.join(
    awful.key(
        {modkey}, " ", function() rofi:show("run") end,
        {description = "Launch Program", group = "awesome"}
    ),
    awful.key(
        {modkey}, "u", function() awful.spawn("rofi-pass") end,
        {description = "Open Passwords", group = "awesome"}
    ),
    awful.key(
        {modkey}, "c", function() rofi:show("calc") end,
        {description = "Open Passwords", group = "awesome"}
    ),
    awful.key(
        {modkey}, "w", function() rofi:show("windows") end,
        {description = "Select Window", group = "client"}
    ),
    awful.key(
        {modkey}, "p", function() rofi:show("allwindows") end,
        {description = "Select Window (all tags)", group = "client"}
    ),
    awful.key(
        {modkey}, 'e', function() awful.spawn('rofimoji') end,
        {description = 'Select an Emoji to copy or insert', group = 'awesome'}
    )
)

return rofi
