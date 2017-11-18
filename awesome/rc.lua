local gears     = require("gears")
local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local naughty   = require("naughty")
local menubar   = require("menubar")
local lain      = require("lain")

require("awful.autofocus")

beautiful.init(os.getenv("HOME").."/.config/awesome/theme.lua")

local dpi = beautiful.xresources.apply_dpi

-- {{{ Error handling
if awesome.startup_errors then
  naughty.notify({ preset = naughty.config.presets.critical,
                   title = "Oops, there were errors during startup!",
                   text = awesome.startup_errors })
end
-- Handle runtime errors after startup
do
  local in_error = false
  awesome.connect_signal("debug::error", function (err)
    -- Make sure we don't go into an endless error loop
    if in_error then return end
    in_error = true

    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, an error happened!",
                     text = tostring(err) })
    in_error = false
  end)
end

terminal = "tilix"
modkey = "Mod4"
altkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
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

mymainmenu = awful.menu({
  items = {
    {"albert", "albert"},
    {"tilix", terminal},
    {"restart", awesome.restart},
    {"quit", awesome.quit}
  }
})

mylauncher = awful.widget.launcher({
  image = '/usr/share/archlinux/icons/archlinux-icon-crystal-32.svg',
  menu = mymainmenu
})

-- Menubar configuration
menubar.utils.terminal = terminal

-- {{{ Wibar
local brightness = require("brightness")

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
  awful.button({ }, 1, function(t) t:view_only() end)
)

local tasklist_buttons = gears.table.join(
  awful.button({ }, 1, function (c)
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
  end),
  awful.button({ }, 4, function ()
    awful.client.focus.byidx(1)
  end),
  awful.button({ }, 5, function ()
    awful.client.focus.byidx(-1)
  end)
)

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

-- Make Tab go down a menu
awful.menu.menu_keys.down = { "Down", "j", "Tab" }

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

local function list_update(w, buttons, label, data, objects)
  awful.widget.common.list_update(w, buttons, label, data, objects)
  -- Set tasklist items to set width of 200
  w:set_max_widget_size(dpi(200))
end

--
-- Widgets we need references to
--
local battery = require('widgets/battery')
local cputemp = require("widgets/cputemp")
local volume  = require("widgets/volume")
local weather = require('widgets/weather')

awful.screen.connect_for_each_screen(function(s)
  -- Wallpaper
  set_wallpaper(s)

  -- Each screen has its own tag table.
  awful.tag(
    { "main", "alpha", "bravo", "slack", "extra" },
    s,
    {
      awful.layout.suit.floating,
      lain.layout.centerwork, -- code
      lain.layout.centerwork, -- terminals
      awful.layout.suit.floating,
      awful.layout.suit.floating
    }
  )

  -- Create an imagebox widget which will contains an icon indicating which layout we're using.
  -- We need one layoutbox per screen.
  s.layoutbox = awful.widget.layoutbox(s)
  s.layoutbox:buttons(gears.table.join(
    awful.button({ }, 1, function () awful.layout.inc( 1) end),
    awful.button({ }, 3, function () awful.layout.inc(-1) end),
    awful.button({ }, 4, function () awful.layout.inc( 1) end),
    awful.button({ }, 5, function () awful.layout.inc(-1) end)
  ))
  -- Create a taglist widget
  s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

  -- Create a tasklist widget
  s.mytasklist = awful.widget.tasklist(
    s,
    awful.widget.tasklist.filter.currenttags,
    tasklist_buttons,
    nil,
    list_update
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
    { -- Left widgets
      layout = wibox.layout.fixed.horizontal,
      mylauncher,
      s.mytaglist
    },
    wibox.container.margin(s.mytasklist, dpi(4), dpi(4), dpi(4), dpi(4)), -- Middle widget
    { -- Right widgets
      layout = wibox.layout.fixed.horizontal,
      require("widgets/gpmdp").container,
      wibox.container.margin(require("widgets/cpugraph"),           dpi(0), dpi(10), dpi(4), dpi(4)),
      require("widgets/storage").container,
      (function()
        if cputemp.enabled then
          return wibox.container.margin(cputemp.widget,             dpi(0), dpi(10), dpi(4), dpi(4))
        else return nil
        end
      end)(),
      (function()
        if battery.battery_enabled then
          return battery.container
        else return nil
        end
      end)(),
      awful.widget.only_on_screen(
        wibox.container.margin(wibox.widget.systray(),              dpi(0), dpi( 5), dpi(4), dpi(4)),
        "primary"
      ),
      wibox.container.margin(weather.icon,                          dpi(0), dpi( 5), dpi(4), dpi(4)),
      wibox.container.margin(weather.widget,                        dpi(0), dpi(10), dpi(4), dpi(4)),
      volume.container,
      wibox.container.margin(require("widgets/clock"),              dpi(0), dpi(10), dpi(4), dpi(4)),
      wibox.container.margin(s.layoutbox,                           dpi(0), dpi(10), dpi(4), dpi(4))
      --                                                             left    right   top     bottom
    }
  }
end)

-- {{{ Key bindings
globalkeys = gears.table.join(
  awful.key({ altkey, "Control" }, "Left",   awful.tag.viewprev,
            {description = "view previous", group = "tag"}),
  awful.key({ altkey, "Control" }, "Right",  awful.tag.viewnext,
            {description = "view next", group = "tag"}),
  awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
            {description = "go back", group = "tag"}),
  awful.key({ modkey, "Control" }, "l", function ()
    awful.spawn("i3lock -c 1B1D1E")
  end),

  awful.key({ altkey, "Control" }, "]", function ()
    lain.util.useless_gaps_resize(5)
  end),
  awful.key({ altkey, "Control" }, "[", function ()
    lain.util.useless_gaps_resize(-5)
  end),

  awful.key({ altkey }, "Tab", function()
    awful.client.focus.byidx(1)
  end),
  awful.key({ modkey,           }, "j",
    function ()
      awful.client.focus.byidx( 1)
    end,
    {description = "focus next by index", group = "client"}
  ),
  awful.key({ modkey,           }, "k",
    function ()
      awful.client.focus.byidx(-1)
    end,
    {description = "focus previous by index", group = "client"}
  ),
  awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
            {description = "show main menu", group = "awesome"}),

  -- Layout manipulation
  awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
            {description = "swap with next client by index", group = "client"}),
  awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
            {description = "swap with previous client by index", group = "client"}),
  awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
            {description = "focus the next screen", group = "screen"}),
  awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
            {description = "focus the previous screen", group = "screen"}),
  awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
            {description = "jump to urgent client", group = "client"}),

  -- Standard program
  awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
            {description = "open a terminal", group = "launcher"}),
  awful.key({ modkey, "Control" }, "r", awesome.restart,
            {description = "reload awesome", group = "awesome"}),
  awful.key({ modkey, "Shift"   }, "q", awesome.quit,
            {description = "quit awesome", group = "awesome"}),

  awful.key({modkey}, "l",
    function()
      awful.tag.incmwfact( 0.05)
    end,
    {description = "increase master width factor", group = "layout"}
  ),
  awful.key({modkey}, "h",
    function()
      awful.tag.incmwfact(-0.05)
    end,
    {description = "decrease master width factor", group = "layout"}
  ),
  awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
            {description = "increase the number of master clients", group = "layout"}),
  awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
            {description = "decrease the number of master clients", group = "layout"}),
  awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
            {description = "increase the number of columns", group = "layout"}),
  awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
            {description = "decrease the number of columns", group = "layout"}),
  awful.key({ modkey, "Shift"   }, "l", function () awful.layout.inc( 1)                end,
            {description = "select next", group = "layout"}),
  awful.key({ modkey, "Shift"   }, "k", function () awful.layout.inc(-1)                end,
            {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

  volume.globalkeys,

  brightness.globalkeys,

  -- File manager key
  awful.key({ }, "XF86Explorer", function ()
    awful.spawn("xdg-open "..os.getenv("HOME"))
  end),

  -- Window directional movement
  awful.key({ modkey }, "Down", function ()
    awful.client.focus.bydirection("down")
    if client.focus then client.focus:raise() end
  end),
  awful.key({ modkey }, "Up", function ()
    awful.client.focus.bydirection("up")
    if client.focus then client.focus:raise() end
  end),
  awful.key({ modkey }, "Left", function ()
    awful.client.focus.bydirection("left")
    if client.focus then client.focus:raise() end
  end),
  awful.key({ modkey }, "Right", function ()
    awful.client.focus.bydirection("right")
    if client.focus then client.focus:raise() end
  end),

  -- Screenshots
  awful.key({ modkey }, "p", function ()
    awful.spawn("scrot -e 'mv $f ~/Pictures/Screenshots'")
  end),
  awful.key({ modkey }, "o", function ()
    awful.spawn.with_shell("sleep 0.2 && scrot -s -e 'mv $f ~/Pictures/Screenshots'")
  end)
)

clientkeys = gears.table.join(
    awful.key({ modkey }, "f",
      function (c)
        c.fullscreen = not c.fullscreen
        c:raise()
      end,
      {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey,           }, "q",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, }, "a", function(c)
      c.floating = not c.floating
      c.maximized_vertical = false
      c.maximized_horizontal = false
    end, {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_vertical = false
            c.maximized_horizontal = false
            if not c.maximized then
              awful.titlebar.hide(c)
            elseif c.floating then
              awful.titlebar.show(c)
            end
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)

awful.rules.rules = require("rules")

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
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
      wibox.container.margin(awful.titlebar.widget.iconwidget(c), dpi(4), dpi(4), dpi(4), dpi(4)),
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
  -- catch for Albert popup window
  if c.instance == 'albert' and c.type == 'utility' then
    awful.titlebar.hide(c)
    return
  end

  if c.floating then
    awful.titlebar.show(c)
  else
    awful.titlebar.hide(c)
  end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
