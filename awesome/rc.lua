local gears     = require("gears")
local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local naughty   = require("naughty")
local menubar   = require("menubar")
local lain      = require("lain")

require("awful.autofocus")
require("errors")
require("signals")

beautiful.init(os.getenv("HOME").."/.config/awesome/theme.lua")
awesome.set_preferred_icon_size(42)

local dpi       = beautiful.xresources.apply_dpi
local sep       = lain.util.separators
local colors    = beautiful.colors
local terminal  = "xfce4-terminal"
local taglist   = { "main", "alpha", "bravo", "slack", "music" }
local ipairs    = ipairs

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
local volume     = require("widgets/volume")
local screenshot = require("widgets/screenshots")

local function get_screen_type(s)
    -- Get the screen type based on its geometry [ultrawide, widescreen, square]
    local ratio = s.geometry.width / s.geometry.height
    -- > 4/3
    -- 1.3333333333333
    -- > 1920/1080
    -- 1.7777777777778
    -- > 3440/1440
    -- 2.3888888888889
    -- > 1520/1050
    -- 1.447619047619
    -- > 2560/1440
    -- 1.7777777777778
    if ratio < 1.4 then
        return 'square'
    elseif ratio < 1.8 then
        return 'widescreen'
    else
        return 'ultrawide'
    end
end

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

--
-- Shamelessly forked from
-- https://github.com/awesomeWM/awesome/blob/v4.2/lib/awful/widget/common.lua
local function list_update(w, buttons, label, data, objects)
    w:reset()
    for i, o in ipairs(objects) do
        local cache = data[o]
        local ib, tb, bgb, tbm, ibm, l

        if cache then
            tb = cache.tb
        else
            tb = wibox.widget.textbox()
            tb.forced_width = dpi(100)
        end
        local text, bg, bg_image, icon, args = label(o, tb)

        local left_color = i == 1 and beautiful.colors.background or beautiful.colors.grey
        local right_color = i == #objects and beautiful.colors.background or beautiful.colors.grey
        local la = sep.arrow_right(left_color, bg)
        local ra = sep.arrow_right(bg, right_color)

        if cache then
            ib = cache.ib
            tbm = cache.tbm
            ibm = cache.ibm
        else
            ib = wibox.widget.imagebox()
            tbm = wibox.container.margin(tb, dpi(4), dpi(4))
            ibm = wibox.container.margin(ib, dpi(4))

            data[o] = {
                ib  = ib,
                tb  = tb,
                tbm = tbm,
                ibm = ibm,
            }
        end

        local bgb = wibox.container.background()
        local l = wibox.layout.fixed.horizontal()
        l:add(la)
        l:add(ibm)
        l:add(tbm)
        l:add(ra)
        bgb:set_widget(l)
        bgb:buttons(awful.widget.common.create_buttons(buttons, o))

        args = args or {}

        -- The text might be invalid, so use pcall.
        if text == nil or text == "" then
            tbm:set_margins(0)
        else
            if not tb:set_markup_silently(text) then
                tb:set_markup("<i>&lt;Invalid text&gt;</i>")
            end
        end
        bgb:set_bg(bg)
        if icon then
            ib:set_image(icon)
        else
            ib:set_image('/usr/share/icons/elementary/apps/48/application-default-icon.svg')
        end

        w:add(bgb)
    end
end

local function taglist_update(w, buttons, label, data, objects)
    w:reset()
    for i, o in ipairs(objects) do
        local cache = data[o]
        local tb, bgb, tbm, l

        if cache then
            tb = cache.tb
        else
            tb = wibox.widget.textbox()
        end
        local text, bg, bg_image, icon, args = label(o, tb)

        local la = sep.arrow_right(beautiful.colors.background, bg)
        local ra = sep.arrow_right(bg, beautiful.colors.background)

        if cache then
            tbm = cache.tbm
        else
            tbm = wibox.container.margin(tb, dpi(4), dpi(4))

            data[o] = {
                tb  = tb,
                tbm = tbm,
            }
        end

        local bgb = wibox.container.background()
        local l = wibox.layout.fixed.horizontal()
        l:add(la)
        l:add(tbm)
        l:add(ra)
        bgb:set_widget(l)
        bgb:buttons(awful.widget.common.create_buttons(buttons, o))

        args = args or {}
        tb:set_markup_silently(text)
        bgb:set_bg(bg)
        w:add(bgb)
    end
end

local function arrow_block(widget, fg, bg, left, right)
    return {
        layout = wibox.layout.align.horizontal,
        sep.arrow_left(fg, bg),
        wibox.container.background(
            wibox.container.margin(
                widget,
                dpi(left or 5),
                dpi(left or 5),
                beautiful.bar_margin,
                beautiful.bar_margin
            ),
            bg
        )
    }
end

local function arrow_list(blocks)
    local container = {
        layout = wibox.layout.fixed.horizontal,
    }
    local last_color = nil

    for i, block in ipairs(blocks) do
        container[i] = arrow_block(
            block.widget,
            last_color or beautiful.colors.background,
            block.color
        )
        last_color = block.color
    end
    
    return container
end

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)
    local screen_type = get_screen_type(s)

    -- Each screen has its own tag table.
    awful.tag(
        taglist,
        s,
        {
            awful.layout.suit.floating,
            screen_type == 'ultrawide' and lain.layout.centerwork or awful.layout.suit.tile,
            screen_type == 'ultrawide' and lain.layout.centerwork or awful.layout.suit.fair,
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
        ),
        nil,
        taglist_update
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
        list_update,
        wibox.layout.flex.horizontal()
    )
    -- Create the wibox
    s.mywibox  = awful.wibar {
        position = "top",
        screen   = s,
        height   = beautiful.bar_height
    }

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        {
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist
        },
        {
            layout = wibox.layout.fixed.horizontal,
            s.mytasklist,
        },
        {
            layout = wibox.layout.fixed.horizontal,

            arrow_list({
                { widget = require("widgets/gpmdp").container,
                  color = colors.blue },
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
                    screenshot.container,
                    require("widgets/wallpapers").container,
                    require("widgets/arandr").container,
                  }, 
                  color = colors.grey },
                { widget = awful.widget.only_on_screen(wibox.widget.systray(), "primary"),
                  color = colors.background },
                { widget = volume.container,
                  color = colors.blue },
                { widget = require("widgets/weather").container,
                  color = colors.background },
                { widget = require("widgets/clock"),
                  color = colors.yellow },
                { widget = s.layoutbox,
                  color = colors.background }
            })
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
            awful.spawn("rofi -show windowcd")
        end,
        {description = "Select Window", group = "client"}
    ),
    awful.key(
        { modkey, shift  }, "w",
        function()
            awful.spawn("rofi -show window")
        end,
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
