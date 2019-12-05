local awful     = require("awful")
local beautiful = require("beautiful")
local gears     = require("gears")
local wibox     = require("wibox")

local display         = require("util/display")
local FontIcon        = require("util/fonticon")
local SanityContainer = require("util/sanitycontainer")

local colors                 = beautiful.colors
local client_color           = colors.gray
local client_focus_color     = colors.yellow
local client_minimized_color = colors.purple
local client_previous_color  = colors.white

--
-- Function for when you click on a client in the task bar
--
local function client_button(c)
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
end

--
-- Mini widget for client icons
--
local function create_client_window_icon()
    local icon_container = wibox.layout.fixed.horizontal()

    local client_icon = wibox.widget.imagebox()
    local client_fonticon = FontIcon()

    local container = SanityContainer {
        widget = wibox.widget {
            layout = wibox.layout.fixed.horizontal,
            icon_container
        },
        left = true,
    }

    function container.set_icon(icon, color)
        icon_container:reset()
        container:set_color(color)
        icon_container:add(client_icon)

        client_icon:set_image(icon)
    end

    function container.set_font_icon(name, color)
        icon_container:reset()
        container:set_color(color)
        icon_container:add(client_fonticon)

        client_fonticon:update(name or display.get_default_client_icon(), color)
    end

    return container
end

--local focused_client_fonticon = FontIcon()
local focused_client_name = wibox.widget.textbox()
local focused_client_container_fonticon = SanityContainer {
    widget = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        --focused_client_fonticon,
        focused_client_name
    },
    left = true,
}

local function create_update_function(s)
    local function update_func(window_list, buttons, label, data, clients)
        window_list:reset()

        if #clients == 0 then
            return
        end

        if not data.client_icons then
            data["client_icons"] = {}
        end

        -- window icons
        local previous_client = awful.client.focus.history.get(s, 1)
        for idx, c in ipairs(clients) do
            local client_icon = c.icon
            local icon_override = display.get_icon_for_client(c)
            local color = client_color

            if c == client.focus then
                color = client_focus_color
            elseif c.minimized then
                color = client_minimized_color
            elseif c == previous_client then
                color = client_previous_color
            end

            local container = data.client_icons[idx] or create_client_window_icon()
            data.client_icons[idx] = container

            if icon_override or not client_icon then
                -- no true icon or we've overridden it
                container.set_font_icon(icon_override, color)
            else
                -- going with the real app icon here, display the imagebox
                container.set_icon(client_icon, color)
            end

            container:buttons(awful.widget.common.create_buttons(buttons, c))
            container:set_tooltip(string.format('%s (%s)', c.name, c.class))
            window_list:add(container)
        end

        -- focused client
        if client.focus then
            local client_name = client.focus.name
            local color = client_focus_color

            local container = focused_client_container_fonticon

            -- update the client name and only show if it's focused or last
            if client_name then
                focused_client_name:set_markup_silently(string.format(
                    '<span color="%s">%s</span>',
                    color, client_name
                ))
            end

            -- update the tooltip
            container:set_tooltip(string.format('%s (%s)', client_name, client.focus.class))

            -- update the container color
            container:set_color(color == client_color and colors.background or color)

            container:buttons(awful.widget.common.create_buttons(buttons, client.focus))

            window_list:add(container)
        end
    end

    return update_func
end

local function factory(args)
    local screen = args.screen

    return awful.widget.tasklist {
        screen = screen,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = gears.table.join(
            awful.button({ }, 1, client_button)
        ),
        update_function = create_update_function(screen),
        layout = {
            fill_space = false,
            layout  = wibox.layout.fixed.horizontal
        }
    }
end

return factory
