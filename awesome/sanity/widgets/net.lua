local string = string

local gears        = require('gears')
local Container    = require('sanity/util/container')
local FontIcon     = require('sanity/util/fonticon')
local Graph        = require('sanity/util/graph')
local icon         = require('sanity/util/icon')
local number       = require('sanity/util/number')
local rofi_service = require('sanity/util/rofi')
local text         = require('sanity/util/text')
local timer        = require('sanity/util/timer')

local button = require('awful.button')
local menu   = require('awful.menu')
local spawn  = require('awful.spawn')
local net    = require('lain.widget.net')
local fixed  = require('wibox.layout.fixed')
local widget = require('wibox.widget')

local disconnect_color = colors.white
local color            = colors.orange
local no_connection    = '\u{f701}'
local wifi_connected   = '\u{faa8}'
local wired_connected  = '\u{f6ff}'
local vpn_enabled      = '\u{f983}'
local vpn_disabled     = ''

local network_icon  = FontIcon {icon = no_connection, color = color, small = true}
local vpn_icon      = FontIcon {icon = vpn_disabled,  color = color, small = true}
local network_graph = Graph {color = color, scale = true}

local empty_str = ''

local net_menu = menu({
    theme = { width = 120 },
    items = {
        {'Networks', function()
            timer.delay(rofi_service.network)
        end, icon.get_path('devices', 'network-wireless')},
        {'VPN', function()
            timer.delay(rofi_service.vpn)
        end, icon.get_path('devices', 'network-vpn')},
    }
})

local container = Container {
    widget = widget {
        layout = fixed.vertical,
        widget {
            layout = fixed.horizontal,
            network_icon, vpn_icon
        },
        network_graph.container
    },
    color = color,
    buttons = gears.table.join(
        button({}, 1, function()
            net_menu:toggle()
        end)
    )
}

local nmcli_command = 'nmcli -t | grep %s | grep connect | awk \'{ print $4,$5,$6,$7,$8,$9 }\''

local function query_nmcli(device_name, callback)
    local command = string.format(nmcli_command, device_name)
    spawn.easy_async_with_shell(command, callback)
end

local function update_network_tooltip(network, up, down, wifi_signal)
    local signal = empty_str

    if wifi_signal then
        local quality
        if wifi_signal >= -50 then      quality = 100
        elseif wifi_signal <= -100 then quality = 0
        else                            quality = 2 * (wifi_signal + 100) end
        signal = string.format(' %s%% (%s dBm) \n ', quality, wifi_signal)
        network = string.format(' SSID: %s ', text.trim(network))
    end

    query_nmcli('VPN', function(stdout)
        local vpn = empty_str
        if stdout ~= empty_str then
            vpn = string.format(' VPN: %s ', stdout)
        end

        container:set_tooltip_color(' Network ', string.format(
            '%s\n%s%s %s \u{f63b} %s \u{f63e} ', network, signal, vpn, down, up
        ))
    end)
end

local tunnel_name = 'tun0'

local function network_update()
    network_graph:add_value(tonumber(net_now.received + net_now.sent), 0)
    local down = number.human_bytes(net_now.received, 0, 2)
    local up   = number.human_bytes(net_now.sent, 0, 2)

    local wired = false
    local wifi  = false
    local wifi_signal

    for interface_name, interface in pairs(net_now.devices) do
        if interface_name ~= tunnel_name then
            if interface.ethernet then
                wired = interface_name
            elseif interface.wifi then
                wifi = interface_name
                wifi_signal = interface.signal
            end
        end
    end

    query_nmcli(tunnel_name, function(stdout)
        local is_vpn_enabled = stdout ~= empty_str

        if is_vpn_enabled then
            vpn_icon:update(vpn_enabled, color)
        else
            vpn_icon:update(vpn_disabled, color)
        end

        if wired then
            network_icon:update(wired_connected, color)
            update_network_tooltip(' Wired ', up, down, false)
        elseif wifi then
            network_icon:update(wifi_connected, color)
            query_nmcli(wifi, function(s)
                update_network_tooltip(s, up, down, wifi_signal)
            end)
        else
            -- no interfaces were connected
            network_icon:update(no_connection, disconnect_color)
            update_network_tooltip(net_now.carrier)
            vpn_icon:update(vpn_disabled, disconnect_color)
        end
    end)
end

net {
    timeout    = graph_interval,
    units      = 1,
    wifi_state = 'on',
    eth_state  = 'on',
    settings   = network_update
}

return container
