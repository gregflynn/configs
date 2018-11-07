local awful     = require("awful")
local beautiful = require("beautiful")
local wibox     = require("wibox")
local gears     = require("gears")
local naughty   = require("naughty")

local lain = require("lain")

local FontIcon = require("util/fonticon")
local number   = require("util/number")
local text     = require("util/text")

local colors = beautiful.colors
local markup = lain.util.markup


local none  = "\u{f701}"
local wifi  = "\u{faa8}"
local wired = "\u{f6ff}"
local connection_icon = FontIcon { icon = none, color = colors.red }

local tooltip   = awful.tooltip {}
local function set_tooltip(network, wifi_signal)
    local suffix_text = ""

    if wifi_signal then
        local quality

        if wifi_signal >= -50 then
            quality = 100
        elseif wifi_signal <= -100 then
            quality = 0
        else
            quality = 2 * (wifi_signal + 100)
        end

        suffix_text = string.format(" %s%% (%s dBm)", quality, wifi_signal)
    end

    tooltip.text = string.format("Network: %s%s", network, suffix_text)
end

local up_text   = wibox.widget.textbox()
local down_text = lain.widget.net {
    units = 1,
    wifi_state = "on",
    eth_state = "on",
    settings = function()
        local down = number.human_bytes(net_now.received, 0, 2)
        local up   = number.human_bytes(net_now.sent, 0, 2)
        widget:set_markup(markup.fg.color(colors.background, text.pad(down, 4)))
        up_text:set_markup(markup.fg.color(colors.background, text.pad(up, 4)))

        -- check interfaces for any that are connected
        for interface_name, interface in pairs(net_now.devices) do
            if interface.ethernet then
                connection_icon:update(wired, colors.purple)
                set_tooltip("Wired")
                return
            elseif interface.wifi then
                local command = string.format(
                    "nmcli -t | grep %s | grep connected | awk '{ print $4,$5,$6,$7,$8,$9 }'",
                    interface_name
                )

                connection_icon:update(wifi, colors.green)
                awful.spawn.easy_async(
                    { awful.util.shell, "-c", command },
                    function(stdout)
                        set_tooltip(stdout, interface.signal)
                    end
                )
                return
            end
        end

        -- no interfaces were connected
        connection_icon:update(none, colors.red)
        set_tooltip(net_now.carrier)
    end
}

local netwidget = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    connection_icon,
    down_text,
    FontIcon { icon = "\u{f103}", color = colors.green },
    up_text,
    FontIcon { icon = "\u{f102}", color = colors.red },
}
tooltip:add_to_object(netwidget)

return netwidget
