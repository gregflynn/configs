local string, tonumber = string, tonumber

local beautiful = require('beautiful')
local gears     = require('gears')
local Container = require('sanity/util/container')
local FontIcon  = require('sanity/util/fonticon')
local Graph     = require('sanity/util/graph')
local display   = require('sanity/util/display')
local file      = require('sanity/util/file')
local icon      = require('sanity/util/icon')
local text      = require('sanity/util/text')

local button   = require('awful.button')
local menu     = require('awful.menu')
local screen   = require('awful.screen')
local spawn    = require('awful.spawn')
local watch    = require('awful.widget.watch')
local markup   = require('lain.util.markup')
local redshift = require('lain.widget.contrib.redshift')
local widget   = require('wibox.widget')
local fixed    = require('wibox.layout.fixed')

local wallpapers_folder   = beautiful.dotsan_home..'/modules/private/wallpapers'
local screenlayout_folder = beautiful.home..'/.screenlayout/'
local folder_command      = 'ls -l %s | awk \'{print $9}\' | tail -n 35 | sort'
local color               = colors.blue
local gpu_has_metrics     = false
local gpu_icon            = FontIcon {icon = '\u{f03d}', color = color, large = true}
local gpu_temp
local gpu_graph_container
local gpu_container

local blinky_on      = true
local screen_lock_on = true

local text_enabled  = 'On'
local text_disabled = 'Off'

local function update_tooltip()
    gpu_container:set_tooltip_color(' Graphics ', string.format(
        '    Redshift: %s \n Screen Lock: %s ',
        redshift.active and text_enabled or text_disabled,
        screen_lock_on and text_enabled or text_disabled
    ))
end

function toggle_screen_lock()
    if screen_lock_on then
        spawn({'xautolock', '-disable'})
        spawn({'xset', 's', 'off'})
        spawn({'xset', '-dpms'})
    else
        spawn({'xautolock', '-enable'})
        spawn({'xset', 's', 'on'})
        spawn({'xset', '+dpms'})
    end
    screen_lock_on = not screen_lock_on
    update_tooltip()
end

local gpu_menu = menu({
    theme = {width = 220},
    items = {
        {'Monitors', function() spawn('arandr') end, icon.get_path('devices', 'video-display')},
        {'Toggle Redshift', function() redshift:toggle() end},
        {'Toggle Screen Lock', toggle_screen_lock},
    }
})

function toggle_blinky()
    if blinky_on then
        spawn({'blinky', '--off'})
    else
        spawn({'blinky', '--on'})
    end
    blinky_on = not blinky_on
end

if file.exists('/usr/bin/blinky') then
    gpu_menu:add({'Toggle Blinky LEDs', toggle_blinky})
end

spawn.easy_async_with_shell(string.format(folder_command, wallpapers_folder), function(stdout)
    local wp_menu = {}

    for item in stdout:gmatch('%S+') do
        local full_path = string.format('%s/%s', wallpapers_folder, item)
        wp_menu[#wp_menu+1] = {
            item,
            function()
                screen.connect_for_each_screen(function(s)
                    gears.wallpaper.maximized(full_path, s)
                end)
            end,
            full_path
        }
    end

    gpu_menu:add({'Wallpapers', wp_menu})
end)

if file.exists(screenlayout_folder) then
    spawn.easy_async_with_shell(string.format(folder_command, screenlayout_folder), function(stdout)
        local sl_menu = {}

        for item in stdout:gmatch('%S+') do
            sl_menu[#sl_menu+1] = {
                item,
                function()
                    local full_path = string.format('%s/%s', screenlayout_folder, item)
                    spawn(string.format('bash %s', full_path))
                end
            }
        end

        gpu_menu:add({'Screen Layouts', sl_menu})
    end)
end

if file.exists('/usr/bin/nvidia-smi') and not file.exists('/proc/acpi/bbswitch') then
    gpu_has_metrics = true
    color = colors.green

    local gpu_graph = Graph {color = color}
    gpu_graph_container = gpu_graph.container
    gpu_temp = watch(
        'nvidia-smi --format=csv,nounits,noheader --query-gpu=temperature.gpu,utilization.gpu',
        graph_interval,
        function(w, stdout)
            local split_stdout = text.split(stdout, ', ')
            local temp = text.trim(split_stdout[1])
            local load = text.trim(split_stdout[2])

            w:set_markup(markup.fg.color(color, temp..'°C'))
            gpu_graph:add_value(tonumber(load) / 100.0)
        end
    )
end

gpu_container = Container {
    color = color,
    widget = gpu_has_metrics and widget {
        layout = fixed.vertical,
        display.center(gpu_temp),
        gpu_graph_container,
    } or display.center(gpu_icon),
    buttons = gears.table.join(
        button({}, 1, function() gpu_menu:toggle() end),
        button({}, 3, function() gpu_menu:toggle() end)
    )
}

redshift:attach(nil, update_tooltip)
update_tooltip()

return gpu_container
