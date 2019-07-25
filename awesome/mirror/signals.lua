local awful     = require("awful")
local beautiful = require("beautiful")
local gears     = require("gears")
local wibox     = require("wibox")

local display  = require("util/display")
local FontIcon = require("util/fonticon")

local colors = beautiful.colors
local dpi    = beautiful.xresources.apply_dpi

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

    c.shape = beautiful.border_shape
end)

function should_show_titlebars(client)
    return not (client.requests_no_titlebar or not client.floating) and not client.maximized
end

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

    local icon_widget
    local font_icon
    local font_icon_override = display.get_icon_for_client(c)

    if font_icon_override then
        font_icon = FontIcon {
            icon  = font_icon_override,
            color = colors.white
        }
        icon_widget = wibox.container.margin(
            font_icon,
            dpi(2), dpi(2), dpi(2), dpi(2)
        )
    else
        icon_widget = wibox.container.margin(
            awful.titlebar.widget.iconwidget(c),
            dpi(4), dpi(4), dpi(4), dpi(4)
        )
    end

    c.update_titlebar = function(event)
        if font_icon_override and font_icon then
            if event == "focus" then
                font_icon:update(font_icon_override, beautiful.fg_focus)
            elseif event == "unfocus" then
                font_icon:update(font_icon_override, beautiful.fg_normal)
            end
        end
    end

    awful.titlebar(c) : setup {
        { -- Left
            icon_widget,
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                -- align  = "center",
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

    if not should_show_titlebars(c) then
        awful.titlebar.hide(c)
    end

    c.maximized_vertical = false
    c.maximized_horizontal = false
end)

client.connect_signal("property::floating", function(c)
    if should_show_titlebars(c) then
        awful.titlebar.show(c)
    else
        awful.titlebar.hide(c)
    end
end)

client.connect_signal("property::maximized", function(client)
    if client.maximized then
        client.border_width = 0
        client.shape = nil
    else
        client.border_width = beautiful.border_width
        client.shape = beautiful.border_shape
    end
end)

client.connect_signal("property::fullscreen", function(client)
    -- TODO make this work with wibar.ontop
    -- no idea why this only works with `client.maximized` but not `client.fullscreen`
    if client.maximized then
        client.border_width = 0
        client.shape = nil
    else
        client.border_width = beautiful.border_width
        client.shape = beautiful.border_shape
    end
end)

client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus

    if c.update_titlebar then
        c.update_titlebar("focus")
    end
end)

client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal

    if c.update_titlebar then
        c.update_titlebar("unfocus")
    end
end)

client.connect_signal("request::activate", function(c, context, hints)
    c.minimized = false
    awful.ewmh.activate(c, context, hints)
end)

client.connect_signal("property::urgent", function()
    awful.client.urgent.jumpto(false)
end)
