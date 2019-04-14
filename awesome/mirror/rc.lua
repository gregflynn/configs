-- Global bootstrapping
local beautiful = require("beautiful")
local home      = os.getenv("HOME")
beautiful.init(home.."/.config/awesome/theme.lua")

-- The Rest
local awful   = require("awful")
local gears   = require("gears")
local naughty = require("naughty")

local lain = require("lain")

local ArrowList = require("util/arrowlist")
local display   = require("util/display")
local TagList   = require("util/taglist")
local TaskList  = require("util/tasklist")

require("awful.autofocus")
require("errors")
require("signals")

awesome.set_preferred_icon_size(42)
naughty.config.padding = 30
naughty.config.defaults.margin = 10

local colors   = beautiful.colors
local terminal = "alacritty"

-- disable "AeroSnap" like feature
awful.mouse.snap.edge_enabled = false

-- define keys, not local so widgets can use them
modkey = "Mod4"
altkey = "Mod1"
ctlKey = "Control"
shift  = "Shift"

-- Make Tab go down a menu
awful.menu.menu_keys.down = { "Down", "j", "Tab" }
awful.rules.rules = require("rules")

--
-- Screen setup
--
local battery    = require("widgets/battery")
local brightness = require("widgets/brightness")
local clock      = require("widgets/clock")
local cpu        = require("widgets/cpu")
local rofi       = require("widgets/rofi")
local timer      = require("widgets/timer")
local tray       = require("widgets/tray")
local volume     = require("widgets/volume")
local weather    = require("widgets/weather")

awful.screen.connect_for_each_screen(function(screen)
    display.set_wallpaper(screen)
    screen.mytaglist = TagList { screen = screen }

    -- Create a tasklist widget
    screen.mytasklist = TaskList { screen = screen }

    -- Create the wibox
    screen.mywibar = display.create_wibar(
        screen,
        { screen.mytaglist },
        { screen.mytasklist },
        {
            ArrowList { screen = screen, prefix = true, blocks = {
                { widget = battery, color = colors.green      },
                { widget = cpu,     color = colors.red        },
                { widget = volume,  color = colors.blue,       primary_only = true },
                { widget = tray,    color = colors.orange,     primary_only = true },
                { widget = weather, color = colors.purple     },
                { widget = timer,   color = colors.yellow     },
                { widget = clock,   color = colors.blue       },
            } },
            display.create_layout_widget(screen)
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
        {modkey, ctlKey}, "r", function()
            -- NOTE: pkill here to avoid flicker hell when restarting awesome
            -- and redshift is still running
            os.execute("pkill redshift")
            awesome.restart()
        end,
        {description = "Reload Awesome", group = "awesome"}
    ),
    awful.key(
        {modkey, shift}, "q", awesome.quit,
        {description = "Logout", group = "awesome"}
    ),
    awful.key(
        {modkey}, "s", hotkeys_popup.show_help,
        {description = "Show Keybindings", group = "awesome"}
    ),
    awful.key(
        {modkey}, "Return", function() awful.spawn(terminal) end,
        {description = "Open Terminal", group = "awesome"}
    ),
    awful.key(
        {}, "XF86Explorer", function() awful.spawn("thunar "..home) end
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
        { modkey,        }, "j",
        function()
            awful.client.focus.byidx(-1)
        end,
        {description = "Left Window in List", group = "client"}
    ),
    awful.key(
        { modkey,        }, "k",
        function()
            awful.client.focus.byidx(1)
        end,
        {description = "Right Window in List", group = "client"}
    ),
    awful.key(
        { modkey, ctlKey }, "n",
        function()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                client.focus = c
                c:raise()
            end
        end,
        {description = "Restore Minimized Window", group = "client"}
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
        {modkey, ctlKey}, "h",
        function() awful.tag.incncol(1, nil, true) end,
        {description = "Inc. Column Count", group = "layout"}
    ),
    awful.key(
        {modkey, ctlKey}, "l",
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
        { modkey, shift  }, "]",
        function()
            lain.util.useless_gaps_resize(5)
        end,
        {description = "Inc. Useless Gap", group = "screen"}
    ),
    awful.key(
        { modkey, shift  }, "[",
        function()
            lain.util.useless_gaps_resize(-5)
        end,
        {description = "Dec. Useless Gap", group = "screen"}
    ),
    awful.key(
        { modkey, ctlKey }, "j",
        function()
            awful.screen.focus_relative(1)
        end,
        {description = "Next Screen", group = "screen"}
    ),
    awful.key(
        { modkey, ctlKey }, "k",
        function()
            awful.screen.focus_relative(-1)
        end,
        {description = "Previous Screen", group = "screen"}
    ),

    -- Tag Keys
    TagList { keys = true },

    -- Widget keys
    brightness.globalkeys,
    rofi.globalkeys,
    tray.globalkeys,
    volume.globalkeys
)

-- Set keys
root.keys(globalkeys)
