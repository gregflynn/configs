local client, string = client, string

local awful     = require('awful')
local gears     = require('gears')
local FontIcon  = require('sanity/util/fonticon')
local Container = require('sanity/util/container')
local display   = require('sanity/util/display')
local text      = require('sanity/util/text')

local fixed    = require('wibox.layout.fixed')
local imagebox = require('wibox.widget.imagebox')
local margin   = require('wibox.container.margin')

local client_color           = colors.gray
local client_focus_color     = colors.yellow
local client_minimized_color = colors.purple
local client_unfocus_line    = colors.background

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

local default_font_icon = display.get_default_client_icon()

local function create_client_window_icon(c)
    local icon_container  = fixed.vertical()
    local client_icon     = imagebox()
    local client_fonticon = FontIcon {large = true}
    local icon_override   = display.get_icon_for_client(c)

    local using_font_icon = icon_override or not c.icon

    local container = Container {
        widget = display.center(icon_container),
    }

    if using_font_icon then
        icon_container:add(client_fonticon)
        client_fonticon:update(icon_override or default_font_icon, client_color)
    else
        icon_container:add(margin(client_icon, 5, 5, 0, 0))
        client_icon:set_image(c.icon)
    end

    function container:set_icon_container_color(color, container_color)
        container:set_color(container_color)
        if using_font_icon then
            client_fonticon:update(icon_override or default_font_icon, color)
        end
    end

    return container
end

local function update_func(window_list, buttons, _, data, clients)
    window_list:reset()

    if #clients == 0 then
        return
    end

    if not data.client_icons then
        data.client_icons = {}
    end

    for idx=1, #clients do
        local c     = clients[idx]
        local color = client_color
        local bg_color = client_unfocus_line

        if c == client.focus then
            color = client_focus_color
            bg_color = client_focus_color
        elseif c.minimized then
            color = client_minimized_color
            bg_color = client_minimized_color
        end

        local container = data.client_icons[c]
        if not container then
            container = create_client_window_icon(c)
            container:buttons(awful.widget.common.create_buttons(buttons, c))
            data.client_icons[c] = container
        end

        container:set_icon_container_color(color, bg_color)
        container:set_tooltip_color(
            string.format('%s (%s)', text.trim(c.name), c.class), nil, client_focus_color
        )
        window_list:add(container)
    end
end

local function factory(args)
    return awful.widget.tasklist {
        screen = args.screen,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = gears.table.join(
            awful.button({}, 1, client_button),
            awful.button({}, 3, client_button)
        ),
        update_function = update_func,
        layout = {
            fill_space = false,
            layout     = fixed.vertical
        }
    }
end

return factory
