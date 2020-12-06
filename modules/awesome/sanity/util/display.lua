local beautiful = require('beautiful')
local gears     = require('gears')
local wibox     = require('wibox')

local display = {}
local window_icon_overrides = {
    ['Blueberry.py']                     = '',
    ['Cawbird']                          = '',
    ['Code']                             = '\u{e70c}',
    ['Google-chrome']                    = '\u{f268}',
    ['Evince']                           = '',
    ['feh']                              = '\u{f03e}',
    ['File-roller']                      = '',
    ['firefox']                          = '\u{f269}',
    ['Gimp-2.10']                        = '',
    ['jetbrains-idea']                   = '\u{e7b5}',
    ['jetbrains-pycharm']                = '\u{e73c}',
    ['jetbrains-toolbox']                = '',
    ['kitty']                            = '',
    ['OpenSCAD']                         = '',
    ['Pavucontrol']                      = '墳',
    ['Plexamp']                          = '',
    ['Prusa-slicer']                     = '浪',
    ['pulse-sms']                        = '',
    ['Polari']                           = '\u{f869}',
    ['Seahorse']                         = '',
    ['Slack']                            = '\u{f198}',
    ['Steam']                            = '\u{f1b6}',
    ['Thunar']                           = '',
    ['Todoist']                          = '',
    ['VirtualBox']                       = '\u{fcbe}',
    ['VirtualBox Manager']               = '\u{fcbe}',
    ['zoom']                             = '',
}
local window_icon_fallback = '缾'

local screen_tall   = 'tall'
local screen_square = 'square'
local screen_wide   = 'widescreen'
local screen_ultra  = 'ultrawide'

-- Get the screen type based on its geometry
-- @returns [ultrawide, widescreen, square, tall]
function display.screen_type(screen)
    local ratio = screen.geometry.width / screen.geometry.height
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
    if ratio < 1. then
        return screen_tall
    elseif ratio < 1.4 then
        return screen_square
    elseif ratio < 1.8 then
        return screen_wide
    else
        return screen_ultra
    end
end

-- Set the given screen's wallpaper
function display.set_wallpaper(screen)
    local wallpaper = beautiful.wallpaper
    if wallpaper then
        -- If wallpaper is a function, call it with the screen
        --if type(wallpaper) == 'function' then
        --    wallpaper = wallpaper(s)
        --end
        gears.wallpaper.maximized(wallpaper, screen, false)
    end
end

function display.get_icon_for_client(client)
    return window_icon_overrides[client.class]
end

function display.get_default_client_icon()
    return window_icon_fallback
end

function display.center(widget)
    local ctr = wibox.layout.align.horizontal(nil, widget, nil)
    ctr.expand = 'outside'
    return ctr
end

function display.vertical_bar(bar)
    return wibox.widget {
        {
            bar,
            forced_width = 6,
            direction    = 'east',
            layout       = wibox.container.rotate,
        },
        margins = 4,
        layout  = wibox.container.margin,
    }
end

function display.bubble(layout, right_only, left_only)
    -- no idea why 2x, it's what looked right
    local padding = beautiful.useless_gap * 2
    local margin = wibox.container.margin(
        layout, beautiful.useless_gap, beautiful.useless_gap
    )
    local bg = wibox.container.background(
        margin, colors.background, beautiful.border_shape
    )
    return wibox.container.margin(
        bg, (not right_only) and padding or 0, (not left_only) and padding or 0, padding, 0
    )
end

-- Re-set wallpaper when a screen's geometry changes
screen.connect_signal('property::geometry', display.set_wallpaper)

return display
