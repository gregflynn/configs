local awful     = require("awful")
local beautiful = require("beautiful")
local gears     = require("gears")
local wibox     = require("wibox")

local text            = require("util/text")
local display         = require("util/display")
local FontIcon        = require("util/fonticon")
local SanityContainer = require("util/sanitycontainer")

local rofi_service = require("services/rofi")

local colors = beautiful.colors
local dpi    = beautiful.xresources.apply_dpi

local client_color = colors.gray
local client_focus_color = colors.yellow
local client_minimized_color = colors.purple
local client_maximized_color = colors.green
local name_width = 25
local icon_width = 26

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
-- Un-minimize all minimized clients
--
local function unminimize_all()
    for _, c in ipairs(client.get()) do
        if c.minimized then
            client_button(c)
        end
    end
end

local window_icon = FontIcon {icon = "\u{fab1}", color = client_focus_color}
local window_count = wibox.widget.textbox()
local window_count_container = SanityContainer {
    widget = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        window_icon,
        window_count
    },
    color = client_focus_color,
    left = true,
    tooltip = "Show clients on tag",
    buttons = gears.table.join(awful.button({}, 1, rofi_service.tagwindows))
}

local minimized_window_icon = FontIcon {icon = "\u{faaf}", color = client_minimized_color}
local minimized_count = wibox.widget.textbox()
local minimized_count_container = SanityContainer {
    widget = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        minimized_window_icon,
        minimized_count
    },
    color = client_minimized_color,
    left = true,
    tooltip = "Show clients on tag",
    buttons = gears.table.join(awful.button({}, 1, unminimize_all))
}

local focused_client_icon = wibox.widget.imagebox()
local focused_client_fonticon = FontIcon()
local focused_client_name = wibox.widget.textbox()
local focused_client_container_icon = SanityContainer {
    widget = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        focused_client_icon,
        focused_client_name
    },
    left = true,
}
local focused_client_container_fonticon = SanityContainer {
    widget = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        focused_client_fonticon,
        focused_client_name
    },
    left = true,
}

local function create_update_func(s)
    return function(window_list, buttons, label, data, clients)
        window_list:reset()

        if #clients == 0 then
            return
        end

        -- window count
        window_count:set_markup_silently(string.format(
            '<span color="%s">%s</span>', client_focus_color, #clients
        ))
        window_list:add(window_count_container)

        -- minimized count
        local num_minimized = 0
        for _, c in ipairs(clients) do
            if c.minimized then
                num_minimized = num_minimized + 1
            end
        end
        if num_minimized > 0 then
            minimized_count:set_markup_silently(string.format(
                '<span color="%s">%s</span>', client_minimized_color, num_minimized
            ))
            window_list:add(minimized_count_container)
        end

        -- focused client
        if client.focus then
            local client_name = client.focus.name
            local client_icon = client.focus.icon
            local color = client_focus_color

            if client.focus.maximized then
                color = client_maximized_color
            end

            local container
            local icon_override = display.get_icon_for_client(client.focus)
            if icon_override or not client_icon then
                -- no true icon or we've overridden it
                container = focused_client_container_fonticon
                local name = icon_override or display.get_default_client_icon()
                focused_client_fonticon:update(name, color)
                focused_client_fonticon.forced_width = dpi(icon_width)
            else
                -- going with the real app icon here, display the imagebox
                container = focused_client_container_icon
                focused_client_icon:set_image(client_icon)
                focused_client_icon.forced_width = dpi(icon_width)
            end

            -- update the client name and only show if it's focused or last
            if client_name then
                focused_client_name:set_markup_silently(string.format(
                    '<span color="%s">%s</span>',
                    color, text.trunc(client_name, name_width, false, true)
                ))
            end

            -- update the tooltip
            container:set_tooltip(string.format('%s (%s)', client_name, client.focus.class))

            -- update the container color
            container:set_color(color == client_color and colors.background or color)

            container.forced_width = dpi(250)
            container:buttons(awful.widget.common.create_buttons(buttons, client.focus))

            window_list:add(container)
        end
    end
end

local function factory(args)
    local screen = args.screen

    return awful.widget.tasklist {
        screen = screen,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = gears.table.join(
            awful.button({ }, 1, client_button)
        ),
        update_function = create_update_func(screen),
        layout = {
            fill_space = false,
            layout  = wibox.layout.fixed.horizontal
        }
    }
end

return factory
