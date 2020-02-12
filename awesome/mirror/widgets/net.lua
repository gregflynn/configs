local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')
local gears     = require('gears')

local lain = require('lain')

local number          = require('util/number')
local FontIcon        = require('util/fonticon')
local Graph           = require('util/graph')
local SanityContainer = require('util/sanitycontainer')
local rofi_service    = require("util/rofi")

local colors = beautiful.colors


local color = colors.orange
local no_connection   = "\u{f701}"
local wifi_connected  = "\u{faa8}"
local wired_connected = "\u{f6ff}"

local vpn_icon      = FontIcon { icon = "\u{f983}", color = color }
local network_icon  = FontIcon { icon = no_connection, color = colors.white }
local network_graph = Graph {stack_colors = {color, colors.red}}
network_graph.scale = true
vpn_icon.visible = false

local container = SanityContainer {
    widget = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        vpn_icon,
        network_icon,
        network_graph.container
    },
    color = color,
    buttons = gears.table.join(
        awful.button({}, 1, function()
            rofi_service.network()
        end)
    )
}

local function query_nmcli(device_name, callback)
    local command = string.format(
        "nmcli -t | grep %s | grep connected | awk '{ print $4,$5,$6,$7,$8,$9 }'",
        device_name
    )

    awful.spawn.easy_async(
        { awful.util.shell, "-c", command },
        function(stdout)
            callback(stdout)
        end
    )
end

local function update_vpn_icon()
    query_nmcli("tun0", function(stdout)
        vpn_icon.visible = stdout ~= ""
    end)
end

local function update_network_tooltip(network, up, down, wifi_signal)
    local signal = ""

    if wifi_signal then
        local quality
        if wifi_signal >= -50 then      quality = 100
        elseif wifi_signal <= -100 then quality = 0
        else                            quality = 2 * (wifi_signal + 100) end
        signal = string.format('%s%% (%s dBm)', quality, wifi_signal)
    end

    container:set_tooltip_color(string.format(
        'Network: %s%s\n%s \u{f63b} %s \u{f63e}', network, signal, down, up
    ))
end

local function network_update()
    network_graph:add_value(tonumber(net_now.received), 0)
    network_graph:add_value(tonumber(net_now.sent), 1)
    local down = number.human_bytes(net_now.received, 0, 2)
    local up   = number.human_bytes(net_now.sent, 0, 2)

    -- check interfaces for any that are connected
    for interface_name, interface in pairs(net_now.devices) do
        if interface.ethernet then
            network_icon:update(wired_connected, color)
            update_network_tooltip("Wired", up, down)
            update_vpn_icon()
            return
        elseif interface.wifi then
            network_icon:update(wifi_connected, color)
            query_nmcli(interface_name, function(stdout)
                update_network_tooltip(stdout, up, down, interface.signal)
            end)
            update_vpn_icon()
            return
        end
    end

    -- no interfaces were connected
    network_icon:update(no_connection, colors.white)
    update_network_tooltip(net_now.carrier)
end

lain.widget.net {
    units      = 1,
    wifi_state = 'on',
    eth_state  = 'on',
    settings   = network_update
}

return container
