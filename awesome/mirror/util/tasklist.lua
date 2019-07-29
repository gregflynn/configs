local awful     = require("awful")
local beautiful = require("beautiful")
local gears     = require("gears")
local wibox     = require("wibox")

local display  = require("util/display")
local FontIcon = require("util/fonticon")
local SanityContainer = require('util/sanitycontainer')

local colors = beautiful.colors
local dpi    = beautiful.xresources.apply_dpi


local client_color = colors.gray
local client_focus_color = colors.yellow
local client_minimized_color = colors.purple
local spacer = SanityContainer {
    widget = FontIcon {icon = "\u{e216}", color = client_color},
    color = colors.background,
    left = true,
    no_tooltip = true
}

local function create_update_func(s)
    local function client_icon(c, color)
        local ib, name
        local icon = c.icon
        local icon_override = display.get_icon_for_client(c)

        if icon_override or not icon then
            -- no true icon or we've overridden it
            ib = FontIcon()
            name = icon_override or display.get_default_client_icon()
            ib:update(name, color)
        elseif not ib then
            -- going with the real app icon here, display the imagebox
            ib = wibox.widget.imagebox()
            ib:set_image(icon)
        end

        ib.forced_width = dpi(26)
        return ib, name
    end

    local function listupdate_windows(window_list, buttons, label, data, clients)
        window_list:reset()
        if #clients > 0 then
            window_list:add(spacer)
        end

        for _, c in ipairs(clients) do
            local cache = data[c]
            local ib, tb, sc, iname

            local color = client_color

            if client.focus == c then
                color = client_focus_color
            elseif c.minimized then
                color = client_minimized_color
            end

            if cache then
                ib  = cache.ib
                tb  = cache.tb
                sc  = cache.sc
                iname = cache.iname
            else
                ib, iname = client_icon(c, color)
                tb = wibox.widget.textbox()
                sc = SanityContainer {
                    widget = wibox.widget {
                        layout = wibox.layout.fixed.horizontal,
                        ib,
                        --tb
                    },
                    left    = true,
                    color   = color,
                    buttons = awful.widget.common.create_buttons(buttons, c)
                }
                data[c] = {
                    ib = ib,
                    tb = tb,
                    sc = sc,
                    iname = iname
                }
            end

            if iname then
                ib:update(iname, color)
            end

            -- update the tooltip
            sc:set_tooltip(string.format('%s (%s)', c.name, c.class))

            -- update the container color
            sc:set_color(color == client_color and colors.background or color)

            window_list:add(sc)
        end

        if client.focus.screen == s then
            local cache = data["NAME"]
            local nb

            if cache then
                nb = cache.nb
            else
                nb = wibox.widget.textbox()
            end

            window_list:add(spacer)

            nb:set_markup_silently(string.format(
                '<span color="%s">%s</span>',
                client_focus_color, client.focus.name
            ))

            window_list:add(SanityContainer {
                widget = wibox.widget {
                    layout = wibox.layout.fixed.horizontal,
                    client_icon(client.focus, client_focus_color),
                    nb
                },
                left       = true,
                color      = colors.background,
                no_tooltip = true,
                buttons    = awful.widget.common.create_buttons(buttons, client.focus)
            })
        end

    end

    return listupdate_windows
end

local function factory(args)
    local screen = args.screen

    return awful.widget.tasklist {
        screen = screen,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = gears.table.join(
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
        update_function = create_update_func(screen),
        layout = {
            fill_space = false,
            layout  = wibox.layout.fixed.horizontal
        }
    }
end

return factory
