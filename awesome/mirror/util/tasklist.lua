local awful     = require("awful")
local beautiful = require("beautiful")
local gears     = require("gears")
local wibox     = require("wibox")

local Arrow    = require("util/arrow")
local display  = require("util/display")
local FontIcon = require("util/fonticon")
local text     = require("util/text")

local colors = beautiful.colors

local dpi = beautiful.xresources.apply_dpi

local window_icon_overrides = {
    ["Alacritty"]                        = "\u{f489}",
    ["Google-chrome"]                    = "\u{f268}",
    ["Firefox"]                          = "\u{f269}",
    ["jetbrains-idea"]                   = "\u{e7b5}",
    ["jetbrains-pycharm"]                = "\u{e73c}",
    ["Google Play Music Desktop Player"] = "\u{f001}",
    ["Slack"]                            = "\u{f198}",
    ["Thunar"]                           = "\u{f413}"
}
local window_icon_fallback = "\u{fb13}"

local max_full_clients = {
    ["tall"] = 3,
    ["square"] = 5,
    ["widescreen"] = 6,
    ["ultrawide"] = 10,
}

local function create_update_func(screen)
    local screen = screen
    local max_full_clients = max_full_clients[display.screen_type(screen)]

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
                arr = Arrow { widget = wibox.layout.fixed.horizontal(), right = true }
            end

            local title, bg, _, icon = label(client, tb)
            local fg_color = text.select(title, "'")

            -- Update the textbox
            local text_width = dpi(100)
            if no_text then
                title = ""
                text_width = 0
            end
            tb:set_markup_silently(title)
            tb.forced_width = text_width

            -- Update the icon
            local icon_override = window_icon_overrides[client.class]
            if icon_override or not icon then
                -- no true icon or we've overridden it
                if not ib then
                    ib = FontIcon()
                end
                local unicode = icon_override or window_icon_fallback
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
                arr.widget:add(ib)
                arr.widget:add(tb)

                data[client] = {
                    ib  = ib,
                    tb  = tb,
                    arr = arr
                }
            end

            arr:update(bg, colors.background, colors.background)
            arr:buttons(awful.widget.common.create_buttons(buttons, client))
            window_list:add(arr)
        end
    end

    return listupdate_windows
end

local function factory(args)
    local screen = args.screen

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
        create_update_func(screen),
        wibox.layout.flex.horizontal()
    )
end

return factory