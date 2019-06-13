local awful     = require("awful")
local beautiful = require("beautiful")
local gears     = require("gears")
local wibox     = require("wibox")

local display  = require("util/display")
local FontIcon = require("util/fonticon")
local text     = require("util/text")
local SanityContainer = require('util/sanitycontainer')

local colors = beautiful.colors
local dpi    = beautiful.xresources.apply_dpi


local max_full_clients = {
    ["tall"] = 3,
    ["square"] = 5,
    ["widescreen"] = 6,
    ["ultrawide"] = 20,
}

local function create_update_func(screen)
    local screen = screen
    local max_full_clients = max_full_clients[display.screen_type(screen)]

    local function client_details(client, tb, label, no_text)
        local title, bg_color, _, icon = label(client, tb)
        local fg_color = text.select(title, "'")
        local name = client.name

        if no_text then name = '' end

        -- title, fg color, bg color, icon
        return name, fg_color, bg_color, icon
    end

    local function listupdate_windows(window_list, buttons, label, data, clients)
        window_list:reset()

        local no_text = #clients > max_full_clients

        for idx, client in ipairs(clients) do
            local cache = data[client]
            local ib, tb, c

            if cache then
                ib  = cache.ib
                tb  = cache.tb
                c   = cache.c
            else
                tb = wibox.widget.textbox()
            end

            local title, fg_color, bg_color, icon = client_details(client, tb, label, no_text)
            
            function is_focus()
                return fg_color == beautiful.tasklist_fg_focus
            end

            if is_focus() then
                tb:set_markup_silently('<span color="'..fg_color..'">'..text.trunc(title, 20)..'</span>')
            else
                tb:set_markup_silently('')
            end

            -- Update the icon
            local icon_override = display.get_icon_for_client(client)
            if icon_override or not icon then
                -- no true icon or we've overridden it
                if not ib then
                    ib = FontIcon()
                end
                local unicode = icon_override or display.get_default_client_icon()
                ib:update(unicode, fg_color)
            elseif not ib then
                -- going with the real app icon here, display the imagebox
                ib = wibox.widget.imagebox()
                ib:set_image(icon)
            end

            if not cache then
                ib.forced_width = dpi(24)

                c = SanityContainer {
                    widget = wibox.widget {
                        layout = wibox.layout.fixed.horizontal,
                        ib,
                        tb
                    },
                    left    = true,
                    color   = fg_color,
                    buttons = awful.widget.common.create_buttons(buttons, client)
                }

                data[client] = {
                    ib = ib,
                    tb = tb,
                    c  = c
                }
            end

            -- update the tooltip
            c:set_tooltip(string.format('%s (%s)', client.name, client.class))

            -- update the container color
            c:set_color(fg_color)

            window_list:add(c)
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
