local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')
local gears     = require('gears')

local lain = require('lain')

local Graph    = require('util/graph')
local FontIcon = require("util/fonticon")
local number   = require("util/number")
local Toggle   = require("util/toggle")

local colors = beautiful.colors
local dpi    = beautiful.xresources.apply_dpi
local naughty = require('naughty')

local no_connection   = "\u{f701}"
local wifi_connected  = "\u{faa8}"
local wired_connected = "\u{f6ff}"
local network_icon    = FontIcon { icon = no_connection, color = colors.white }
local network_tooltip = awful.tooltip { objects = {network_icon} }
local network_graph   = Graph {stack_colors = {colors.green, colors.red}}
network_graph.scale = true

local function update_network_tooltip(network, up, down, wifi_signal)
    local signal = ""

    if wifi_signal then
        local quality
        if wifi_signal >= -50 then      quality = 100
        elseif wifi_signal <= -100 then quality = 0
        else                            quality = 2 * (wifi_signal + 100) end
        signal = string.format(" %s%% (%s dBm)", quality, wifi_signal)
    end

    -- network_graph:add_value(up, 1)
    
    network_tooltip.text = string.format(
        "Network: %s%s\n%s \u{f63b} %s \u{f63e}", network, signal, down, up
    )
end

local function network_update()
    network_graph:add_value(tonumber(net_now.received), 0)
    network_graph:add_value(tonumber(net_now.sent), 1)
    local down = number.human_bytes(net_now.received, 0, 2)
    local up   = number.human_bytes(net_now.sent, 0, 2)

    -- check interfaces for any that are connected
    for interface_name, interface in pairs(net_now.devices) do
        if interface.ethernet then
            network_icon:update(wired_connected, colors.orange)
            update_network_tooltip("Wired", up, down)
            return
        elseif interface.wifi then
            local command = string.format(
                "nmcli -t | grep %s | grep connected | awk '{ print $4,$5,$6,$7,$8,$9 }'",
                interface_name
            )

            network_icon:update(wifi_connected, colors.orange)
            awful.spawn.easy_async(
                { awful.util.shell, "-c", command },
                function(stdout)
                    update_network_tooltip(stdout, up, down, interface.signal)
                end
            )
            return
        end
    end

    -- no interfaces were connected
    network_icon:update(no_connection, colors.white)
    update_network_tooltip(net_now.carrier)
end

lain.widget.net {
    units      = 1,
    wifi_state = "on",
    eth_state  = "on",
    settings   = network_update
}

network_icon:buttons(gears.table.join(
    awful.button({}, 1, function()
        awful.spawn("networkmanager_dmenu")
    end)
))


local container = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    network_icon,
    network_graph.container
}
return wibox.container.margin(container, 0, dpi(4), 0, 0)
