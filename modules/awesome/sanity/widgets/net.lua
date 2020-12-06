local string = string

local Container    = require('sanity/util/container')
local FontIcon     = require('sanity/util/fonticon')

local spawn  = require('awful.spawn')
local net    = require('lain.widget.net')
local fixed  = require('wibox.layout.fixed')
local widget = require('wibox.widget')

local disconnect_color = colors.red
local color            = colors.white
local no_connection    = '\u{f701}'
local wifi_connected   = '\u{faa8}'
local wired_connected  = '\u{f6ff}'
local vpn_enabled      = '\u{f983}'
local vpn_disabled     = ''

local network_icon  = FontIcon {icon = no_connection, color = color}
local vpn_icon      = FontIcon {icon = vpn_disabled,  color = color}

local empty_str = ''

local container = Container {
    widget = widget {
        layout = fixed.horizontal,
        network_icon,
        vpn_icon,
    },
    color = color,
    no_tooltip = true,
}

local nmcli_command = 'nmcli -t | grep %s | grep connect | awk \'{ print $4,$5,$6,$7,$8,$9 }\''

local function query_nmcli(device_name, callback)
    local command = string.format(nmcli_command, device_name)
    spawn.easy_async_with_shell(command, callback)
end

local function network_update()
    local wired = false
    local wifi  = false
    local wifi_signal

    for interface_name, interface in pairs(net_now.devices) do
        if interface_name ~= 'tun0' then
            if interface.ethernet then
                wired = interface_name
            elseif interface.wifi then
                wifi = interface_name
                wifi_signal = interface.signal
            end
        end
    end

    query_nmcli('VPN', function(stdout)
        local is_vpn_enabled = stdout ~= empty_str

        if is_vpn_enabled then
            vpn_icon:update(vpn_enabled, color)
        else
            vpn_icon:update(vpn_disabled, color)
        end

        if wired then
            network_icon:update(wired_connected, color)
        elseif wifi then
            network_icon:update(wifi_connected, color)
        else
            -- no interfaces were connected
            network_icon:update(no_connection, disconnect_color)
            vpn_icon:update(vpn_disabled, disconnect_color)
        end
    end)
end

net {
    timeout    = 2,
    units      = 1,
    wifi_state = 'on',
    eth_state  = 'on',
    settings   = network_update
}

return container
