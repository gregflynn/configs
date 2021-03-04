-- Global bootstrapping
local beautiful = require('beautiful')
local home      = os.getenv('HOME')
beautiful.init(home..'/.config/awesome/sanity/theme.lua')
colors = beautiful.colors

-- The Rest
local awful   = require('awful')
local gears   = require('gears')
local naughty = require('naughty')
local wibox   = require('wibox')
local machi   = require('layout-machi')
local display = require('sanity/util/display')

require('awful.autofocus')
require('sanity/errors')
require('sanity/signals')

awesome.set_preferred_icon_size(22)
naughty.config.padding = 30
naughty.config.defaults.margin = 10
naughty.config.presets.critical = {fg = colors.background, bg = colors.red, timeout = 0}

beautiful.layout_machi = machi.get_icon()
machi.default_editor.set_gap(beautiful.useless_gap * 2, beautiful.useless_gap * 2)

-- disable 'AeroSnap' like feature
awful.mouse.snap.edge_enabled = false

tags       = {         '',         '',          '',           '',        ''}
tag_colors = {colors.green, colors.blue, colors.white, colors.orange, colors.red}

-- define keys, not local so widgets can use them
modkey = 'Mod4'
altkey = 'Mod1'
ctlkey = 'Control'
shift  = 'Shift'

terminal = 'kitty'

function create_key(k, group, desc, f)
    return awful.key({modkey}, k, f, {description = desc, group = group})
end

function create_mod_key(m, k, group, desc, f)
    return awful.key({modkey, m}, k, f, {description = desc, group = group})
end

function create_root_key(k, f)
    return awful.key({}, k, f)
end

-- Make Tab go down a menu
awful.menu.menu_keys.down = {'Down', 'j', 'Tab'}
awful.menu.menu_keys.close = {'q', 'Escape'}
awful.rules.rules = require('sanity/rules')

--
-- Services
--
local brightness_service = require('sanity/util/brightness')
local rofi_service       = require('sanity/util/rofi')

--
-- Screen setup
--
local TagList = require('sanity/widgets/tag')
local volume  = require('sanity/widgets/volume')

awful.screen.connect_for_each_screen(function(screen)
    local screen_type = display.screen_type(screen)

    display.set_wallpaper(screen)
    awful.tag(tags, screen, {
        screen_type == 'ultrawide' and awful.layout.suit.floating or machi.default_layout
    })

    screen.mytaglist = TagList.factory { screen = screen }

    -- Create a tasklist widget
    screen.mytasklist = require('sanity/widgets/tasklist') { screen = screen }

    -- Create the wibox
    screen.mywibar = awful.wibar {
        position = 'top',
        ontop    = true,
        screen   = screen,
        height   = beautiful.bar_height,
        opacity  = beautiful.bar_opacity,
        bg       = '#00000000',
    }

    screen.mywibar:setup {
        layout = wibox.layout.align.horizontal,
        {
            layout = wibox.layout.fixed.horizontal,
            screen.mytaglist,
            screen.mytasklist,
        },
        nil,
        {
            layout = wibox.layout.fixed.horizontal,
            display.bubble(wibox.widget {
                layout = wibox.layout.fixed.horizontal,
                require('sanity/widgets/net'),
                require('sanity/widgets/screenlock'),
                require('sanity/widgets/redshift'),
                require('sanity/widgets/battery'),
                volume,
                require('sanity/widgets/tray'),
            }, true),
            display.bubble(require('sanity/widgets/clock'), true)
        }
    }
end)


--
-- Client Switcher
--
local switcher = require('sanity/util/switcher')

--
-- Keybindings
--
local hotkeys_popup = require('awful.hotkeys_popup').widget

globalkeys = gears.table.join(
    --
    -- Awesome
    --
    create_mod_key(ctlkey, 'r', 'awesome', 'Reload Awesome', function()
        os.execute('pkill redshift')
        awesome.restart()
    end),
    create_mod_key(shift, '/', 'awesome', 'Show Keybindings', hotkeys_popup.show_help),
    create_key('Return', 'awesome', 'Raise/Open Terminal', function()
        -- try to find a terminal on this tag already
        for _, c in ipairs(awful.screen.focused().selected_tag:clients()) do
            if c.class == terminal then
                c:jump_to(false)
                return
            end
        end
        awful.spawn(terminal)
    end),
    create_mod_key(shift, 'Return', 'awesome', 'Open New Terminal', function()
        awful.spawn(terminal)
    end),
    create_key('i', 'awesome', 'Lock Screen', function()
        awful.spawn({'bash', beautiful.lock_script})
    end),
    create_key('y', 'awesome', 'Toggle Top Bar', function()
        awful.screen.focused().mywibar.visible = not awful.screen.focused().mywibar.visible
    end),
    create_key('d', 'awesome', 'Open Directory', function()
        awful.spawn({'xdg-open', home})
    end),


    --
    -- Client
    --
    create_key('Tab', 'client', 'Last Client', function()
        switcher.switch(1, modkey, 'Super_L', shift, 'Tab')
    end),
    create_mod_key(shift, 'Tab', 'client', 'Next Client', function()
        switcher.switch(-1, modkey, 'Super_L', shift, 'Tab')
    end),
    create_key('j', 'client', 'Previous Client', function()
        awful.client.focus.byidx(-1)
    end),
    create_key('k', 'client', 'Next Client', function()
        awful.client.focus.byidx(1)
    end),
    create_mod_key(shift, 'm', 'client', 'Minimize tag clients', function()
        for _, c in ipairs(awful.screen.focused().selected_tag:clients()) do
            c.minimized = true
        end
    end),

    --
    -- Layout
    --
    create_key('/', 'layout', 'Edit Layout', function()
        if awful.screen.focused().selected_tag.layout ~= machi.default_layout then
            awful.screen.focused().selected_tag.layout = machi.default_layout
        else
            machi.default_editor.start_interactive()
        end
    end),
    create_key('l', 'layout', 'Toggle Layout', function()
        local l = awful.screen.focused().selected_tag.layout
        if l.name == 'floating' then
            awful.screen.focused().selected_tag.layout = machi.default_layout
        else
            awful.screen.focused().selected_tag.layout = awful.layout.suit.floating
        end
    end),

    --
    -- Screen
    --
    create_key('o', 'screen', 'Take Screenshot', function()
        awful.spawn({'flameshot', 'gui'})
    end),
    create_mod_key(shift, 'o', 'screen', 'Record Screen', function()
        awful.spawn('peek')
    end),

    --
    -- Rofi
    --
    create_key(' ', 'awesome', 'Launch Program', rofi_service.run),
    create_key('u', 'awesome', 'Open Passwords', rofi_service.pass),
    create_key('c', 'awesome', 'Calculator', rofi_service.calc),
    create_key('w', 'awesome', 'Select Window', rofi_service.tagwindows),
    create_key('p', 'awesome', 'Select Window (all tags)', rofi_service.allwindows),
    create_key('e', 'awesome', 'Select Emoji', rofi_service.emoji),
    create_key('s', 'awesome', 'Search Web', rofi_service.websearch),
    create_key('a', 'awesome', 'System Actions', rofi_service.actions),
    create_mod_key(shift, 'p', 'awesome', 'Open Projects', rofi_service.projects),

    --
    -- Tag Keys
    ---
    create_key('Left', 'awesome', 'Previous Tag', function()
        awful.tag.viewprev()
        TagList.show_popup(awful.screen.focused().selected_tag.index)
    end),
    create_key('Right', 'awesome', 'Next Tag', function()
        awful.tag.viewnext()
        TagList.show_popup(awful.screen.focused().selected_tag.index)
    end),

    --
    -- Brightness Control
    --
    create_root_key('XF86MonBrightnessUp', brightness_service.up),
    create_root_key('XF86MonBrightnessDown', brightness_service.down),

    --
    -- Audio
    --
    create_root_key('XF86AudioRaiseVolume', function()
        awful.spawn('pactl set-sink-volume @DEFAULT_SINK@ +5%')
        volume.lain_widget.notify()
    end),
    create_root_key('XF86AudioLowerVolume', function()
        awful.spawn('pactl set-sink-volume @DEFAULT_SINK@ -5%')
        volume.lain_widget.notify()
    end),
    create_root_key('XF86AudioMute', function()
        awful.spawn('pactl set-sink-mute @DEFAULT_SINK@ toggle')
        volume.lain_widget.notify()
    end)
)

local function create_tag_keys(idx, override)
    local tag_name = tags[idx]
    local key = '#'..(idx + 9)
    if override then
        key = '#'..(override + 9)
    end

    globalkeys = gears.table.join(
        globalkeys,
        create_key(key, 'tag', 'View '..tag_name, function()
            local tag = awful.screen.focused().tags[idx]
            if tag then
                if tag ~= awful.screen.focused().selected_tag then
                    tag:view_only()
                end
                TagList.show_popup(idx)
            end
        end),
        create_mod_key(shift, key, 'tag', 'Move client to '..tag_name, function()
            if client.focus then
                local tag = client.focus.screen.tags[idx]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end)
    )
end

for i = 1, #tags * 2 do
    if i < 6 then
        create_tag_keys(i)
    else
        create_tag_keys(i - 5, i)
    end
end

-- Set keys
root.keys(globalkeys)
