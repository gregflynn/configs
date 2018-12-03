local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local gears     = require("gears")
local lain      = require("lain")

local dpi = beautiful.xresources.apply_dpi


local display = {}

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

function display.create_layout_widget(screen)
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

    local widget = awful.widget.layoutbox(screen)

    widget:buttons(gears.table.join(
        awful.button({ }, 1, function() awful.layout.inc( 1) end),
        awful.button({ }, 3, function() awful.layout.inc(-1) end),
        awful.button({ }, 4, function() awful.layout.inc( 1) end),
        awful.button({ }, 5, function() awful.layout.inc(-1) end)
    ))

    return wibox.container.margin(widget, dpi(6), dpi(6), dpi(4), dpi(4))
end

function display.create_wibar(screen, left, center, right)
    local wibar = awful.wibar {
        position = "top",
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


-- Re-set wallpaper when a screen's geometry changes
screen.connect_signal("property::geometry", display.set_wallpaper)


return display
