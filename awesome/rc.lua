local gears     = require("gears")
local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local naughty   = require("naughty")
local menubar   = require("menubar")
local lain      = require("lain")

require("awful.autofocus")
require("errors")

beautiful.init(os.getenv("HOME").."/.config/awesome/theme.lua")

local dpi = beautiful.xresources.apply_dpi
local terminal = "xfce4-terminal"

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

--
-- Screen setup
--
local battery    = require('widgets/battery')
local cputemp    = require("widgets/cputemp")
local volume     = require("widgets/volume")
local screenshot = require("widgets/screenshots")

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
            if type(wallpaper) == "function" then
                wallpaper = wallpaper(s)
            end
            gears.wallpaper.maximized(wallpaper, s, false)
        end
    end
    
-- Re-set wallpaper when a screen's geometry changes
screen.connect_signal("property::geometry", set_wallpaper)

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

local taglist = { "main", "alpha", "bravo", "slack", "extra" }
awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag(
        taglist,
        s,
        {
            awful.layout.suit.floating,
            lain.layout.centerwork, -- code
            lain.layout.centerwork, -- terminals
            awful.layout.suit.floating,
            awful.layout.suit.floating
        }
    )

    -- Create an imagebox widget which will contains an icon indicating which
    -- layout we're using. We need one layoutbox per screen.
    s.layoutbox = awful.widget.layoutbox(s)
    s.layoutbox:buttons(gears.table.join(
        awful.button({ }, 1, function() awful.layout.inc( 1) end),
        awful.button({ }, 3, function() awful.layout.inc(-1) end),
        awful.button({ }, 4, function() awful.layout.inc( 1) end),
        awful.button({ }, 5, function() awful.layout.inc(-1) end)
    ))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(
        s,
        awful.widget.taglist.filter.all,
        gears.table.join(
            awful.button({ }, 1, function(t) t:view_only() end)
        )
    )

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(
        s,
        awful.widget.tasklist.filter.currenttags,
        gears.table.join(
            awful.button({ }, 1, function(c)
                if c == client.focus then
                    c.minimized = true
                else
                    -- Without this, the following
                    -- :isvisible() makes no sense
                    c.minimized = false
                    if not c:isvisible() and c.first_tag then
                        c.first_tag:view_only()
                    end
                    -- This will also un-minimize
                    -- the client, if needed
                    client.focus = c
                    c:raise()
                end
            end)
        ),
        nil,
        function(w, buttons, label, data, objects)
            awful.widget.common.list_update(w, buttons, label, data, objects)
            -- Set tasklist items to set width of 200
            w:set_max_widget_size(dpi(200))
        end
    )
    -- Create the wibox
    s.mywibox  = awful.wibar {
        position = "top",
        screen   = s,
        height   = dpi(25)
    }

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        {
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist
        },
        wibox.container.margin(s.mytasklist, dpi(4), dpi(4), dpi(4), dpi(4)),
        {
            layout = wibox.layout.fixed.horizontal,
            require("widgets/gpmdp").container,
            wibox.container.margin(
                require("widgets/cpugraph"), dpi(0), dpi(10), dpi(4), dpi(4)
            ),
            require("widgets/mempie").container,
            require("widgets/storage").container,
            (function()
                if cputemp.enabled then
                    return wibox.container.margin(
                        cputemp.widget, dpi(0), dpi(10), dpi(4), dpi(4)
                    )
                else return nil
                end
            end)(),
            screenshot.container,
            (function()
                if battery.battery_enabled then
                    return battery.container
                else return nil
                end
            end)(),
            awful.widget.only_on_screen(
                wibox.container.margin(wibox.widget.systray(),
                dpi(0), dpi(5), dpi(4), dpi(4)),
                "primary"
            ),
            require('widgets/weather').container,
            volume.container,
            wibox.container.margin(
                require("widgets/clock"), dpi(0), dpi(10), dpi(4), dpi(4)
            ),
            wibox.container.margin(
                s.layoutbox, dpi(0), dpi(10), dpi(4), dpi(4)
            )
        }
    }
end)

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
            awful.spawn("xdg-open "..os.getenv("HOME"))
        end
        -- {description = "Home Directory", group = "programs"}
    ),
    awful.key(
        { modkey,        }, "i",
        function()
            awful.spawn("i3lock -c 272822")
        end,
        {description = "Lock Screen", group = "awesome"}
    ),
    awful.key(
        { modkey,        }, " ",
        function()
            awful.spawn("rofi -show drun")
        end,
        {description = "Launch Program", group = "awesome"}
    ),
    awful.key(
        { modkey, shift  }, " ",
        function()
            awful.spawn("rofi -show ssh")
        end,
        {description = "Open SSH", group = "awesome"}
    ),

    --
    -- Client
    --
    awful.key(
        { modkey,        }, "w",
        function()
            awful.spawn("rofi -show window")
        end,
        {description = "Select Window", group = "client"}
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

-- Bind all key numbers to tags.
for i = 1, 5 do
    local tag_name = taglist[i]

    globalkeys = gears.table.join(
        globalkeys,
        awful.key(
            { modkey }, "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end,
            {description = "View "..tag_name, group = "tag"}
        ),
        awful.key(
            { modkey, "Control" }, "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end,
            {description = "Toggle " .. tag_name, group = "tag"}
        ),
        awful.key(
            { modkey, "Shift" }, "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            {description = "Move Window to " .. tag_name, group = "tag"}
        )
    )
end

--
-- Client keys
--
clientkeys = require("clientkeys")

clientbuttons = gears.table.join(
    awful.button({ }, 1, function(c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
)

-- Set keys
root.keys(globalkeys)

awful.rules.rules = require("rules")

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end
    awful.client.setslave(c)

    if awesome.startup and
        not c.size_hints.user_position
            and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            wibox.container.margin(
                awful.titlebar.widget.iconwidget(c),
                dpi(4), dpi(4), dpi(4), dpi(4)
            ),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.minimizebutton(c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }

    if not c.floating then
        awful.titlebar.hide(c)
    end

    c.maximized_vertical = false
    c.maximized_horizontal = false
end)

client.connect_signal("property::floating", function (c)
    if c.floating then
        awful.titlebar.show(c)
    else
        awful.titlebar.hide(c)
    end
end)

client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus
end)

client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
end)
