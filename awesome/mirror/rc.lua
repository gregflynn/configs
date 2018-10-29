local gears     = require("gears")
local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local menubar   = require("menubar")
local lain      = require("lain")

local bar        = require("util/bar")
local display    = require("util/display")

require("awful.autofocus")
require("errors")
require("signals")
local home = os.getenv("HOME")

beautiful.init(home.."/.config/awesome/theme.lua")
awesome.set_preferred_icon_size(42)

local colors    = beautiful.colors
local terminal  = "alacritty"
local taglist   = { "main", "alpha", "bravo", "slack", "music" }

-- define keys, not local so widgets can use them
-- yea yea globals bad yea yea
modkey = "Mod4"
altkey = "Mod1"
ctlKey = "Control"
shift  = "Shift"

-- Menubar configuration
menubar.utils.terminal = terminal

-- Make Tab go down a menu
awful.menu.menu_keys.down = { "Down", "j", "Tab" }
awful.rules.rules = require("rules")

--
-- Screen setup
--
local volume     = require("widgets/volume")
local screenshot = require("widgets/screenshots")

-- screen layout cycle list
awful.layout.layouts = {
    awful.layout.suit.floating,
    lain.layout.centerwork,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal
}

awful.screen.connect_for_each_screen(function(screen)
    display.set_wallpaper(screen)
    screen.mytaglist = display.create_taglist_widget(taglist, screen)

    -- Create a tasklist widget
    screen.mytasklist = display.create_windowlist_widget(screen)

    -- Create the wibox
    screen.mywibar = display.create_wibar(
        screen,
        {
            screen.mytaglist,
            display.create_layout_widget(screen)
        },
        {
            screen.mytasklist,
        },
        {
            bar.arrow_left_list({
                { widget = require("widgets/gpmdp").container,
                  color = colors.yellow },
                { widget = wibox.widget {
                    layout = wibox.layout.fixed.horizontal,
                    require("widgets/cpugraph"),
                    require("widgets/cputemp").container,
                    require("widgets/mempie").container,
                    require("widgets/storage").container,
                    require("widgets/battery").container,
                  },
                  color = colors.background },
                { widget = wibox.widget {
                    layout = wibox.layout.fixed.horizontal,
                    require("widgets/blinky").container,
                    require("widgets/caffeine").container,
                    screenshot.container,
                    require("widgets/wallpapers").container,
                    require("widgets/arandr").container,
                  },
                  color = colors.purple },
                { widget = volume.container,
                  color = colors.gray },
                { widget = require("widgets/weather").container,
                  color = colors.background },
                { widget = require("widgets/clock"),
                  color = colors.blue },
            })
        })
end)


local function rofi(method)
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

--
-- Keybindings
--
local brightness = require("brightness")
local hotkeys_popup = require("awful.hotkeys_popup").widget

globalkeys = gears.table.join(
    --
    -- Awesome
    --
    awful.key(
        { modkey, ctlKey }, "r",
        awesome.restart,
        {description = "Reload Awesome", group = "awesome"}
    ),
    awful.key(
        { modkey, shift  }, "q",
        awesome.quit,
        {description = "Logout", group = "awesome"}
    ),
    awful.key(
        { modkey,        }, "s",
        hotkeys_popup.show_help,
        {description = "Show Keybindings", group = "awesome"}
    ),
    awful.key(
        { modkey,        }, "Return",
        function()
            awful.spawn(terminal)
        end,
        {description = "Open Terminal", group = "awesome"}
    ),
    awful.key(
        {                }, "XF86Explorer",
        function()
            awful.spawn("thunar "..home)
        end
        -- {description = "Home Directory", group = "programs"}
    ),
    awful.key(
        { modkey,        }, "i",
        function()
            awful.spawn({"bash", beautiful.lock_script})
        end,
        {description = "Lock Screen", group = "awesome"}
    ),
    awful.key(
        {modkey}, " ",
        function() rofi("run") end,
        {description = "Launch Program", group = "awesome"}
    ),
    awful.key(
        {modkey, shift}, " ",
        function() rofi("ssh") end,
        {description = "Open SSH", group = "awesome"}
    ),
    awful.key(
        {modkey}, "u",
        function() rofi("pass") end,
        {description = "Open Passwords", group = "awesome"}
    ),
    awful.key(
        {modkey}, "c",
        function() rofi("calc") end,
        {description = "Open Passwords", group = "awesome"}
    ),

    --
    -- Client
    --
    awful.key(
        {modkey}, "w",
        function() rofi("windows") end,
        {description = "Select Window", group = "client"}
    ),
    awful.key(
        {modkey, shift}, "w",
        function() rofi("allwindows") end,
        {description = "Select Window (all tags)", group = "client"}
    ),
    awful.key(
        { modkey,        }, "Tab",
        function ()
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
        { modkey,           }, "u",
        awful.client.urgent.jumpto,
        {description = "Jump To Urgent Window", group = "client"}
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
        { modkey,        }, "l",
        function()
            awful.tag.incmwfact(0.05)
        end,
        {description = "Inc. Master Width", group = "layout"}
    ),
    awful.key(
        { modkey,        }, "h",
        function()
            awful.tag.incmwfact(-0.05)
        end,
        {description = "Dec. Master Width", group = "layout"}
    ),
    awful.key(
        { modkey, shift  }, "h",
        function()
            awful.tag.incnmaster(1, nil, true)
        end,
        {description = "Inc. Master Client Count", group = "layout"}
    ),
    awful.key(
        { modkey, shift  }, "l",
        function()
            awful.tag.incnmaster(-1, nil, true)
        end,
        {description = "Dec. Master Client Count", group = "layout"}
    ),
    awful.key(
        { modkey, ctlKey }, "h",
        function()
            awful.tag.incncol(1, nil, true)
        end,
        {description = "Inc. Column Count", group = "layout"}
    ),
    awful.key(
        { modkey, ctlKey }, "l",
        function()
            awful.tag.incncol(-1, nil, true)
        end,
        {description = "Dec. Column Count", group = "layout"}
    ),
    awful.key(
        { modkey, shift  }, "k",
        function()
            awful.layout.inc(1)
        end,
        {description = "Next Layout", group = "layout"}
    ),
    awful.key(
        { modkey, shift  }, "j",
        function()
            awful.layout.inc(-1)
        end,
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

    --
    -- Tags
    --
    awful.key(
        { modkey,        }, "Left",
        awful.tag.viewprev,
        {description = "Previous Tag", group = "tag"}
    ),
    awful.key(
        { modkey,        }, "Right",
        awful.tag.viewnext,
        {description = "Next Tagt", group = "tag"}
    ),
    awful.key(
        { modkey,        }, "Escape",
        awful.tag.history.restore,
        {description = "Restore Tag", group = "tag"}
    ),

    -- Widget keys
    volume.globalkeys,
    brightness.globalkeys,
    screenshot.globalkeys
)

function add_tag_keys(idx, override)
    local tag_name = taglist[idx]
    local key = '#'..(idx + 9)
    if override then
        key = '#'..(override + 9)
    end

    globalkeys = gears.table.join(
        globalkeys,
        awful.key(
            { modkey }, key,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[idx]
                if tag then
                    tag:view_only()
                end
            end,
            {description = "View "..tag_name, group = "tag"}
        ),
        awful.key(
            { modkey, "Control" }, key,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[idx]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end,
            {description = "Toggle " .. tag_name, group = "tag"}
        ),
        awful.key(
            { modkey, "Shift" }, key,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[idx]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            {description = "Move Window to " .. tag_name, group = "tag"}
        )
    )
end

-- Bind all key numbers to tags.
for i = 1, 10 do
    if i < 6 then
        add_tag_keys(i)
    else
        add_tag_keys(i - 5, i)
    end
end

-- Set keys
root.keys(globalkeys)
