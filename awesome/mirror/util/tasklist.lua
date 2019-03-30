local awful     = require("awful")
local beautiful = require("beautiful")
local gears     = require("gears")
local wibox     = require("wibox")

local display  = require("util/display")
local FontIcon = require("util/fonticon")
local text     = require("util/text")

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
            local ib, tb, arr

            if cache then
                ib  = cache.ib
                tb  = cache.tb
                arr = cache.arr
            else
                tb = wibox.widget.textbox()
                arr = wibox.layout.fixed.horizontal()
            end

            local title, fg_color, bg_color, icon = client_details(client, tb, label, no_text)
            tb:set_markup_silently('<span color="'..fg_color..'">'..text.trunc(title, 20)..'</span>')

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

                -- create the tooltip only once
                awful.tooltip { objects = {arr}, text = client.name }

                -- add the icon and text only once
                arr:add(ib)
                arr:add(tb)

                data[client] = {
                    ib  = ib,
                    tb  = tb,
                    arr = arr
                }
            end

            local ln_color = bg_color
            if client.minimized then
                ln_color = colors.purple
            elseif ln_color == colors.background then
                ln_color = colors.gray
            end
            local ln = wibox.container.background(wibox.widget.base.make_widget(), ln_color)
            ln.forced_height = 2
            local v = wibox.layout.align.vertical(
                nil, wibox.container.margin(arr, dpi(3), dpi(3), dpi(2), dpi(1)), ln
            )
            v:buttons(awful.widget.common.create_buttons(buttons, client))
            window_list:add(v)

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
        layout   = {
            spacing_widget = {
                {
                    forced_width  = 5,
                    forced_height = 10,
                    thickness     = 1,
                    color         = '#777777',
                    widget        = wibox.widget.separator
                },
                valign = 'center',
                halign = 'center',
                widget = wibox.container.place,
            },
            spacing = 20,
            fill_space = false,
            layout  = wibox.layout.fixed.horizontal
        }
    }
end

return factory
