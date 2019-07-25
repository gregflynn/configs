local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local gears     = require("gears")
local lain      = require("lain")

local dpi = beautiful.xresources.apply_dpi


local display = {}
local default_layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.fair,
    awful.layout.suit.floating,
}
local window_icon_overrides = {
    ["Alacritty"]                        = "\u{f489}",
    ["Android Messages"]                 = "\u{f869}",
    ["Code"]                             = "\u{e70c}",
    ["Google-chrome"]                    = "\u{f268}",
    ["firefox"]                          = "\u{f269}",
    ["jetbrains-idea"]                   = "\u{e7b5}",
    ["jetbrains-pycharm"]                = "\u{e73c}",
    ["Google Play Music Desktop Player"] = "\u{f001}",
    ['Ristretto']                        = '\u{f03e}',
    ["Slack"]                            = "\u{f198}",
    ["Steam"]                            = "\u{f1b6}",
    ["Thunar"]                           = "\u{f413}",
    ["Trello"]                           = "\u{fa31}"
}
local window_icon_fallback = "\u{fb13}"

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
        return 'tall'
    elseif ratio < 1.4 then
        return 'square'
    elseif ratio < 1.8 then
        return 'widescreen'
    else
        return 'ultrawide'
    end
end

function display.layouts_for_screen(type)
    if type == 'ultrawide' then
        return {
            awful.layout.suit.floating,
            lain.layout.centerwork,
            awful.layout.suit.tile,
            awful.layout.suit.tile.left,
            awful.layout.suit.fair
        }
    else
        return default_layouts
    end
end

-- Set the given screen's wallpaper
function display.set_wallpaper(screen)
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, screen, false)
    end
end

function display.adjust_layout(amt)
    local screen = awful.screen.focused()
    local screen_type = display.screen_type(screen)
    local screen_layouts = display.layouts_for_screen(screen_type)
    awful.layout.inc(amt, screen, screen_layouts)
end

function display.incr_layout()
    display.adjust_layout(1)
end

function display.decr_layout()
    display.incr_layout(-1)
end

function display.create_layout_widget(screen)
    local widget = awful.widget.layoutbox(screen)

    widget:buttons(gears.table.join(
        awful.button({ }, 1, display.incr_layout),
        awful.button({ }, 3, display.decr_layout),
        awful.button({ }, 4, display.incr_layout),
        awful.button({ }, 5, display.decr_layout)
    ))

    return wibox.container.margin(widget, dpi(0), dpi(0), dpi(4), dpi(4))
end

function display.create_wibar(screen, left, center, right)
    local wibar = awful.wibar {
        position = 'top',
        screen   = screen,
        height   = beautiful.bar_height,
        opacity  = beautiful.bar_opacity
    }

    left.layout = wibox.layout.fixed.horizontal
    center.layout = wibox.layout.fixed.horizontal
    right.layout = wibox.layout.fixed.horizontal

    wibar:setup {
        layout = wibox.layout.align.horizontal,
        left,
        center,
        right
    }

    return wibar
end

function display.get_icon_for_client(client)
    return window_icon_overrides[client.class]
end

function display.get_default_client_icon()
    return window_icon_fallback
end


-- Re-set wallpaper when a screen's geometry changes
screen.connect_signal("property::geometry", display.set_wallpaper)


return display
