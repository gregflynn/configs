local awful     = require("awful")
local beautiful = require("beautiful")
local gears     = require("gears")
local wibox     = require("wibox")

local Arrow    = require("util/arrow")
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

function listupdate_windows(window_list, buttons, label, data, clients)
    window_list:reset()

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
        tb:set_markup_silently(title)

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
            tb.forced_width = dpi(100)

            -- create the tooltip only once
            awful.tooltip {
                objects = {arr},
                text = client.name
--                text = client.class -- useful for rule debugging
            }

            -- add the icon and text only once
            arr.widget:add(ib)
            arr.widget:add(tb)

            data[client] = {
                ib  = ib,
                tb  = tb,
                arr = arr
            }
        end

        arr:update(
            bg,
            idx == #clients and colors.background or colors.gray,
            idx == 1 and colors.background or colors.gray
        )

        arr:buttons(awful.widget.common.create_buttons(buttons, client))
        window_list:add(arr)
    end
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
        listupdate_windows,
        wibox.layout.flex.horizontal()
    )
end

return factory
