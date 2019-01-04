local awful     = require("awful")
local beautiful = require("beautiful")
local wibox     = require("wibox")
local gears     = require("gears")
local naughty   = require("naughty")

local lain = require("lain")

local Dropdown = require("util/dropdown")
local file     = require("util/file")
local FontIcon = require("util/fonticon")
local number   = require("util/number")
local Toggle   = require("util/toggle")

local colors = beautiful.colors
local dpi    = beautiful.xresources.apply_dpi
local gpmdp  = require("widgets/gpmdp")


--
-- redshift
--
local redshift = FontIcon()
local tooltip  = awful.tooltip {
    objects = {redshift},
    text    = "redshift"
}
lain.widget.contrib.redshift:attach(redshift, function(active)
    if active then
        tooltip.text = "Redshift: Active"
        redshift:update("\u{f800}", colors.background)
    else
        tooltip.text = "Redshift: Inactive"
        redshift:update("\u{f800}", colors.white)
    end
end)


--
-- blinky
--
local blinky_command = "blinky"
local blinky_enabled = file.exists("/usr/bin/blinky")
local blinky         = Toggle {
    font_icon_enabled        = "\u{fbe6}",
    font_icon_enabled_color  = colors.background,
    font_icon_disabled       = "\u{fbe7}",
    font_icon_disabled_color = colors.white,
    default_enabled          = true,
    tooltip_text             = "Toggle LED Backlights",
    on_enable = function()
        awful.spawn({blinky_command, "--on"})
    end,
    on_disable = function()
        awful.spawn({blinky_command, "--off"})
    end
}


--
-- caffeine
--
local caffeine = Toggle {
    font_icon_enabled        = "\u{fbc8}",
    font_icon_enabled_color  = colors.background,
    font_icon_disabled       = "\u{f675}",
    font_icon_disabled_color = colors.white,
    default_enabled          = true,
    tooltip_text             = "Toggle Screen Locking",
    on_enable = function()
        awful.spawn({"xautolock", "-enable"})
        awful.spawn({"xset", "s", "on"})
    end,
    on_disable = function()
        awful.spawn({"xautolock", "-disable"})
        awful.spawn({"xset", "s", "off"})
    end
}


--
-- screenshots
--
local screenshots_folder = beautiful.home.."/Pictures/Screenshots"
local screenshot_icon    = Dropdown {
    folder    = screenshots_folder,
    reverse   = true,
    font_icon = "\u{f793}",
    tooltip_text = "Screenshots",
    menu_func = function(full_path)
        awful.spawn(string.format(
            "xclip -selection clipboard -t image/png %s",
            full_path
        ))
        naughty.notify({
            preset =  {
                icon_size = dpi(256),
                timeout   = 2
            },
            icon = full_path,
        })
    end
}


--
-- wallpapers
--
local wallpapers_icon = Dropdown {
    folder    = beautiful.dotsan_home.."/private/wallpapers",
    font_icon = "\u{f878}",
    tooltip_text = "Wallpapers",
    menu_func = function(full_path)
        awful.screen.connect_for_each_screen(function(s)
            gears.wallpaper.maximized(full_path, s)
        end)
    end
}


--
-- arandr
--
local arandr_folder  = beautiful.home.."/.screenlayout/"
local arandr_enabled = file.exists(arandr_folder)
local arandr         = Dropdown {
    folder = arandr_folder,
    font_icon = "\u{f879}",
    right_click = "arandr",
    tooltip_text = "Monitor Configs",
    menu_func = function(full_path)
        awful.spawn(string.format("bash %s", full_path))
    end
}


--
-- network connection
--
local no_connection   = "\u{f701}"
local wifi_connected  = "\u{faa8}"
local wired_connected = "\u{f6ff}"
local network_icon    = FontIcon { icon = no_connection, color = colors.white }
local network_tooltip = awful.tooltip { objects = {network_icon} }
local function update_network_tooltip(network, up, down, wifi_signal)
    local signal = ""

    if wifi_signal then
        local quality
        if wifi_signal >= -50 then      quality = 100
        elseif wifi_signal <= -100 then quality = 0
        else                            quality = 2 * (wifi_signal + 100) end
        signal = string.format(" %s%% (%s dBm)", quality, wifi_signal)
    end

    network_tooltip.text = string.format(
        "Network: %s%s\n%s \u{f63b} %s \u{f63e}", network, signal, down, up
    )
end
local function network_update()
    local down = number.human_bytes(net_now.received, 0, 2)
    local up   = number.human_bytes(net_now.sent, 0, 2)

    -- check interfaces for any that are connected
    for interface_name, interface in pairs(net_now.devices) do
        if interface.ethernet then
            network_icon:update(wired_connected, colors.background)
            update_network_tooltip("Wired", up, down)
            return
        elseif interface.wifi then
            local command = string.format(
                "nmcli -t | grep %s | grep connected | awk '{ print $4,$5,$6,$7,$8,$9 }'",
                interface_name
            )

            network_icon:update(wifi_connected, colors.background)
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
network_icon.buttons = gears.table.join(
    awful.button({}, 1, function()
        awful.spawn("networkmanager_dmenu")
    end)
)


--
-- tray container and global keys
--
local container = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    gpmdp,
    redshift,
    blinky_enabled and blinky or nil,
    caffeine,
    screenshot_icon,
    wallpapers_icon,
    arandr_enabled and arandr or nil,
    network_icon
}
container.globalkeys = gears.table.join(
    awful.key(
        {modkey}, "p",
        function() awful.spawn(string.format(
            "scrot -e 'mv $f %s'", screenshots_folder
        )) end,
        {description = "take full screen screenshot", group = "screen"}
    ),
    awful.key(
        { modkey }, "o",
        function() awful.spawn.with_shell(string.format(
            "sleep 0.2 && scrot -s -e 'mv $f %s'", screenshots_folder
        )) end,
        {description = "take snippet screenshot", group = "screen"}
    )
)

return container
