-- Global bootstrapping
local beautiful = require("beautiful")
local home      = os.getenv("HOME")
beautiful.init(home.."/.config/awesome/theme.lua")

-- The Rest
local awful   = require("awful")
local gears   = require("gears")
local naughty = require("naughty")

local lain = require("lain")

local display   = require("util/display")
local TagList   = require("util/taglist")
local TaskList  = require("util/tasklist")

require("awful.autofocus")
require("errors")
require("signals")

awesome.set_preferred_icon_size(42)
naughty.config.padding = 30
naughty.config.defaults.margin = 10

local terminal = "alacritty"

-- disable "AeroSnap" like feature
awful.mouse.snap.edge_enabled = false

-- define keys, not local so widgets can use them
modkey = "Mod4"
altkey = "Mod1"
ctlkey = "Control"
shift  = "Shift"

-- Make Tab go down a menu
awful.menu.menu_keys.down = {'Down', 'j', 'Tab'}
awful.menu.menu_keys.close = {'q', 'Escape'}
awful.rules.rules = require('rules')

--
-- Screen setup
--
local volume = require('widgets/volume')
local SanityContainer = require('util/sanitycontainer')

awful.screen.connect_for_each_screen(function(screen)
    display.set_wallpaper(screen)
    screen.mytaglist = TagList { screen = screen }

    -- Create a tasklist widget
    screen.mytasklist = TaskList { screen = screen }

    -- Create the wibox
    screen.mywibar = display.create_wibar(
        screen,
        {
            screen.mytaglist,
            screen.mytasklist
        },
        {},
        {
            require('widgets/cpu'),
            require('widgets/gpu'),
            require('widgets/mem'),
            require('widgets/storage'),
            require('widgets/net'),
            volume,
            require('widgets/battery'),
            require('widgets/tray'),
            require('widgets/weather'),
            require('widgets/clock'),
            SanityContainer {widget = display.create_layout_widget(screen)}
        })
end)


--
-- Keybindings
--
local hotkeys_popup = require("awful.hotkeys_popup").widget

globalkeys = gears.table.join(
    --
    -- Awesome
    --
    awful.key(
        {modkey, ctlkey}, "r", function()
            -- NOTE: pkill here to avoid flicker hell when restarting awesome
            -- and redshift is still running
            os.execute("pkill redshift")
            awesome.restart()
        end,
        {description = "Reload Awesome", group = "awesome"}
    ),
    awful.key(
        {modkey}, "/", hotkeys_popup.show_help,
        {description = 'Show Keybindings', group = "awesome"}
    ),
    awful.key(
        {modkey}, "Return", function() awful.spawn(terminal) end,
        {description = "Open Terminal", group = "awesome"}
    ),
    awful.key(
        {}, "XF86Explorer", function() awful.spawn({"thunar", home}) end
    ),
    awful.key(
        {modkey}, "i", function() awful.spawn({"bash", beautiful.lock_script}) end,
        {description = "Lock Screen", group = "awesome"}
    ),

    --
    -- Client
    --
    awful.key(
        {modkey}, "Tab", function()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "Last Window", group = "client"}
    ),
    awful.key(
        {modkey}, "j", function() awful.client.focus.byidx(-1) end,
        {description = "Previous Client", group = "client"}
    ),
    awful.key(
        {modkey}, "k", function() awful.client.focus.byidx(1) end,
        {description = "Next Client", group = "client"}
    ),

    --
    -- Layout
    --
    awful.key(
        {modkey}, "l",
        function() awful.tag.incmwfact(0.05) end,
        {description = "Inc. Master Width", group = "layout"}
    ),
    awful.key(
        {modkey}, "h",
        function() awful.tag.incmwfact(-0.05) end,
        {description = "Dec. Master Width", group = "layout"}
    ),
    awful.key(
        {modkey, shift}, "h",
        function() awful.tag.incnmaster(1, nil, true) end,
        {description = "Inc. Master Client Count", group = "layout"}
    ),
    awful.key(
        {modkey, shift}, "l",
        function() awful.tag.incnmaster(-1, nil, true) end,
        {description = "Dec. Master Client Count", group = "layout"}
    ),
    awful.key(
        {modkey, ctlkey}, "h",
        function() awful.tag.incncol(1, nil, true) end,
        {description = "Inc. Column Count", group = "layout"}
    ),
    awful.key(
        {modkey, ctlkey}, "l",
        function() awful.tag.incncol(-1, nil, true) end,
        {description = "Dec. Column Count", group = "layout"}
    ),
    awful.key(
        {modkey, shift}, "k",
        display.incr_layout,
        {description = "Next Layout", group = "layout"}
    ),
    awful.key(
        {modkey, shift}, "j",
        display.decr_layout,
        {description = "Previous Layout", group = "layout"}
    ),

    --
    -- Screen
    --
    awful.key(
        {modkey, shift}, "]", function() lain.util.useless_gaps_resize(5) end,
        {description = "Inc. Useless Gap", group = "screen"}
    ),
    awful.key(
        {modkey, shift}, "[", function() lain.util.useless_gaps_resize(-5) end,
        {description = "Dec. Useless Gap", group = "screen"}
    ),
    awful.key(
        {modkey, ctlkey}, "j", function() awful.screen.focus_relative(1) end,
        {description = "Next Screen", group = "screen"}
    ),
    awful.key(
        {modkey, ctlkey}, "k", function() awful.screen.focus_relative(-1) end,
        {description = "Previous Screen", group = "screen"}
    ),
    awful.key(
        {modkey}, "o", function() awful.spawn({"flameshot", "gui"}) end,
        {description = "take screenshot", group = "screen"}
    ),
    awful.key(
        {modkey, shift}, "o", function() awful.spawn("peek") end,
        {description = "record screen", group = "screen"}
    ),

    -- Tag Keys
    TagList {keys = true},

    -- Widget keys
    require("brightness").globalkeys,
    require("rofi").globalkeys,
    volume.globalkeys
)

-- Set keys
root.keys(globalkeys)
