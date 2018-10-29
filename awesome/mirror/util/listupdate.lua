local ipairs = ipairs

local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local lain      = require("lain")

local bar      = require("util/bar")
local FontIcon = require("util/fonticon")
local text     = require("util/text")

local dpi = beautiful.xresources.apply_dpi
local sep = lain.util.separators


local listupdate = {}
local window_icon_overrides = {
    ["Alacritty"]                        = "\u{f489}",
    ["Google-chrome"]                    = "\u{f268}",
    ["Firefox"]                          = "\u{f269}",
    ["jetbrains-pycharm"]                = "\u{e73c}",
    ["Google Play Music Desktop Player"] = "\u{f001}",
    ["Slack"]                            = "\u{f198}",
    ["Thunar"]                           = "\u{f413}"
}
local window_icon_fallback = "\u{fb13}"

-- Shamelessly forked from
-- https://github.com/awesomeWM/awesome/blob/v4.2/lib/awful/widget/common.lua
function listupdate.windows(window_list, buttons, label, data, clients)
    local num_clients = #clients

    -- clear out all clients
    window_list:reset()

    for idx, client in ipairs(clients) do
        local cache = data[client]
        local ib, tb, bgb, tbm, ibm, an

        if cache then
            tb  = cache.tb
            ib  = cache.ib
            tbm = cache.tbm
        else
            tb = wibox.widget.textbox()
            -- ib is defined below
            tb.forced_width = dpi(100)
            tbm = bar.margin(tb, 0, 6)
        end

        local title, bg, _, icon = label(client, tb)
        local fg_color = text.select(title, "'")
        tb:set_markup_silently(title)

        -- create either an app icon box or font icon box
        local icon_override = window_icon_overrides[client.class]
        if icon_override or not icon then
            -- no true icon or we've overridden it
            local unicode = icon_override or window_icon_fallback
            if ib then
                ib:update(unicode, fg_color)
            else
                ib = FontIcon {icon = unicode, color = fg_color}
            end
        elseif not ib then
            -- going with the real app icon here, display the imagebox
            -- we assume icon doesn't change
            ib = wibox.widget.imagebox()
            ib:set_image(icon)
            ib = bar.margin(ib, 6, 0)
        end

        if not cache then
            ib.forced_width = dpi(24)

            -- create the tooltip only once
            awful.tooltip {
                objects = {ib, tbm},
                text = client.class
            }

            data[client] = {
                ib  = ib,
                fi  = fi,
                tb  = tb,
                tbm = tbm,
                an  = an
            }
        end

        -- create powerline seps
        local is_first = idx == 1
        local is_last = idx == num_clients
        local left_color = is_first and beautiful.colors.background or beautiful.colors.gray
        local right_color = is_last and beautiful.colors.background or beautiful.colors.gray
        local la = sep.arrow_right(left_color, bg)
        local ra = sep.arrow_right(bg, right_color)

        -- create the window item container
        local bgb = wibox.container.background()
        local l = wibox.layout.fixed.horizontal()
        l:add(la, ib, tbm, ra)
        bgb:set_widget(l)
        bgb:buttons(awful.widget.common.create_buttons(buttons, client))
        bgb:set_bg(bg)
        window_list:add(bgb)
    end
end

-- Tag list update function
function listupdate.tags(w, buttons, label, data, objects)
    local last_bg = beautiful.colors.background
    w:reset()
    for i, o in ipairs(objects) do
        local cache = data[o]
        local tb, tbm

        if cache then
            tb = cache.tb
            tbm = cache.tbm
        else
            tb = wibox.widget.textbox()
            tbm = wibox.container.margin(tb, dpi(4), dpi(4))

            data[o] = {
                tb  = tb,
                tbm = tbm,
            }
        end

        local l = wibox.layout.fixed.horizontal()
        local title, bg, bg_image, icon, args = label(o, tb)
        tb:set_markup_silently(title)

        bg = bg or beautiful.colors.background
        l:add(sep.arrow_right(last_bg, bg))
        l:add(tbm)
        if i == #objects then
            l:add(sep.arrow_right(bg, beautiful.colors.background))
        end

        local bgb = wibox.container.background()
        bgb:set_widget(l)
        bgb:buttons(awful.widget.common.create_buttons(buttons, o))
        bgb:set_bg(bg)
        w:add(bgb)
        last_bg = bg
    end
end


return listupdate
