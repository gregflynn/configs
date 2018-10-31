local awful     = require("awful")
local gears     = require("gears")


local rofi = {}

function rofi:show(method)
    if method == "pass" then
        awful.spawn("rofi-pass")
        return
    end

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

    awful.spawn("rofi -show "..show.." -scroll-method 1 -matching fuzzy")
end

rofi.globalkeys = gears.table.join(
    awful.key(
        {modkey}, " ",
        function() rofi:show("run") end,
        {description = "Launch Program", group = "awesome"}
    ),
    awful.key(
        {modkey, shift}, " ",
        function() rofi:show("ssh") end,
        {description = "Open SSH", group = "awesome"}
    ),
    awful.key(
        {modkey}, "u",
        function() rofi:show("pass") end,
        {description = "Open Passwords", group = "awesome"}
    ),
    awful.key(
        {modkey}, "c",
        function() rofi:show("calc") end,
        {description = "Open Passwords", group = "awesome"}
    ),
    awful.key(
        {modkey}, "w",
        function() rofi:show("windows") end,
        {description = "Select Window", group = "client"}
    ),
    awful.key(
        {modkey, shift}, "w",
        function() rofi:show("allwindows") end,
        {description = "Select Window (all tags)", group = "client"}
    )
)

return rofi
