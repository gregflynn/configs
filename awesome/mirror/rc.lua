-- Global bootstrapping
local beautiful = require("beautiful")
local home      = os.getenv("HOME")
beautiful.init(home.."/.config/awesome/theme.lua")

-- The Rest
local awful   = require("awful")
local gears   = require("gears")
local naughty = require("naughty")
local wibox   = require("wibox")

local lain = require("lain")
local machi = require("layout-machi")

local display   = require("util/display")
local TagList   = require("util/taglist")
local TaskList  = require("util/tasklist")

require("awful.autofocus")
require("errors")
require("signals")

awesome.set_preferred_icon_size(42)
naughty.config.padding = 30
naughty.config.defaults.margin = 10

beautiful.layout_machi = machi.get_icon()
machi.default_editor.set_gap(beautiful.useless_gap * 2, beautiful.useless_gap * 2)

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
-- Services
--
local brightness_service = require("util/brightness")
local rofi_service       = require("util/rofi")

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
    screen.mywibar = awful.wibar {
        position = "top",
        ontop    = true,
        screen   = screen,
        height   = beautiful.bar_height,
        opacity  = beautiful.bar_opacity
    }

    screen.mywibar:setup {
        layout = wibox.layout.align.horizontal,
        {
            layout = wibox.layout.fixed.horizontal,
            screen.mytaglist,
        },
        screen.mytasklist,
        {
            layout = wibox.layout.fixed.horizontal,
            require("widgets/cpu"),
            require("widgets/gpu"),
            require("widgets/mem"),
            require("widgets/storage"),
            require("widgets/net"),
            volume,
            require("widgets/battery"),
            require("widgets/tray"),
            require("widgets/weather"),
            require("widgets/clock"),
            SanityContainer {
                widget = display.create_layout_widget(screen),
                no_tooltip = true
            }
        }
    }
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
        {modkey, shift}, "/", hotkeys_popup.show_help,
        {description = 'Show Keybindings', group = "awesome"}
    ),
    awful.key(
        {modkey}, "Return", function()
            -- try to find a terminal on this tag already
            for _, c in ipairs(client.get()) do
                if c.class == "Alacritty" then
                    for _, t in ipairs(c:tags()) do
                        if t == awful.screen.focused().selected_tag then
                            c:jump_to(false)
                            return
                        end
                    end
                end
            end
            awful.spawn("alacritty")
        end,
        {description = "Open Terminal", group = "awesome"}
    ),
    awful.key(
        {modkey, shift}, "Return", function() awful.spawn("alacritty") end,
        {description = "", group = "awesome"}
    ),
    awful.key(
        {}, "XF86Explorer", function() awful.spawn({"thunar", home}) end
    ),
    awful.key(
        {modkey}, "i", function() awful.spawn({"bash", beautiful.lock_script}) end,
        {description = "Lock Screen", group = "awesome"}
    ),
    awful.key(
        {modkey}, "y", function()
            awful.screen.focused().mywibar.visible = not awful.screen.focused().mywibar.visible
        end,
        {description = "Toggle Top Bar", group = "awesome"}
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
        {modkey}, "/", function()
            if awful.screen.focused().selected_tag.layout ~= machi.default_layout then
                awful.screen.focused().selected_tag.layout = machi.default_layout
            else
                machi.default_editor.start_interactive()
            end
        end,
        {description = "Edit Layout", group = "layout"}
    ),
    awful.key(
        {modkey}, "l", function()
            local l = awful.screen.focused().selected_tag.layout
            if l.name == "floating" then
                awful.screen.focused().selected_tag.layout = machi.default_layout
            else
                awful.screen.focused().selected_tag.layout = awful.layout.suit.floating
            end
        end,
        {description = "Toggle Layout", group = "layout"}
    ),

    --
    -- Screen
    --
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

    --
    -- Rofi
    --
    awful.key(
        {modkey}, " ", rofi_service.run,
        {description = "Launch Program", group = "awesome"}
    ),
    awful.key(
        {modkey}, "u", rofi_service.pass,
        {description = "Open Passwords", group = "awesome"}
    ),
    awful.key(
        {modkey}, "c", rofi_service.calc,
        {description = "Calculator", group = "awesome"}
    ),
    awful.key(
        {modkey}, "w", rofi_service.tagwindows,
        {description = "Select Window", group = "client"}
    ),
    awful.key(
        {modkey}, "p", rofi_service.allwindows,
        {description = "Select Window (all tags)", group = "client"}
    ),
    awful.key(
        {modkey}, "e", rofi_service.emoji,
        {description = "Select an Emoji to copy or insert", group = "awesome"}
    ),
    awful.key(
        {modkey}, "s", rofi_service.websearch,
        {description = "Search the web", group = "awesome"}
    ),
    awful.key(
        {modkey, shift}, "p", rofi_service.projects,
        {description = "Open Projects", group = "awesome"}
    ),
    awful.key(
        {modkey}, "v", rofi_service.vpn,
        {description = "Select VPN", group = "network"}
    ),
    awful.key(
        {modkey, shift}, "v", rofi_service.network,
        {description = "Select Network", group = "network"}
    ),

    --
    -- Brightness Control
    --
    awful.key({}, "XF86MonBrightnessUp", brightness_service.up),
    awful.key({}, "XF86MonBrightnessDown", brightness_service.down),

    -- Tag Keys
    TagList {keys = true},

    -- Widget keys
    volume.globalkeys
)

-- Set keys
root.keys(globalkeys)
