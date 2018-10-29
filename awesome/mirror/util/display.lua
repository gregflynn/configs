local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local gears     = require("gears")
local lain      = require("lain")

local listupdate = require("util/listupdate")

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

function display.create_taglist_widget(taglist, screen)
    local screen_type = display.screen_type(screen)

    awful.tag(
        taglist, screen,
        {
            awful.layout.suit.floating,
            screen_type == 'ultrawide' and lain.layout.centerwork or awful.layout.suit.tile,
            screen_type == 'ultrawide' and lain.layout.centerwork or awful.layout.suit.fair,
            awful.layout.suit.floating,
            awful.layout.suit.floating
        }
    )

    return awful.widget.taglist(
        screen,
        awful.widget.taglist.filter.all,
        gears.table.join(
            awful.button({ }, 1, function(t) t:view_only() end)
        ),
        nil,
        listupdate.tags
    )
end

function display.create_layout_widget(screen)
    local widget = awful.widget.layoutbox(screen)

    widget:buttons(gears.table.join(
        awful.button({ }, 1, function() awful.layout.inc( 1) end),
        awful.button({ }, 3, function() awful.layout.inc(-1) end),
        awful.button({ }, 4, function() awful.layout.inc( 1) end),
        awful.button({ }, 5, function() awful.layout.inc(-1) end)
    ))

    return wibox.container.margin(widget, dpi(3), dpi(3), dpi(4), dpi(4))
end

function display.create_windowlist_widget(screen)
    return awful.widget.tasklist(
        screen,
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
        listupdate.windows,
        wibox.layout.flex.horizontal()
    )
end

function display.create_wibar(screen, left, center, right)
    local wibar = awful.wibar {
        position = "top",
        screen   = screen,
        height   = beautiful.bar_height
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
