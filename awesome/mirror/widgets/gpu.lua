local awful     = require('awful')
local beautiful = require('beautiful')
local gears     = require('gears')
local wibox     = require('wibox')

local lain    = require('lain')

local file            = require('util/file')
local text            = require('util/text')
local FontIcon        = require('util/fonticon')
local Graph           = require('util/graph')
local SanityContainer = require('util/sanitycontainer')

local wallpapers_folder = beautiful.dotsan_home..'/private/wallpapers'
local screenlayout_folder = beautiful.home..'/.screenlayout/'
local folder_command = "ls -l %s | awk '{print $9}' | tail -n 35 | sort"
local color = beautiful.colors.green
local gpu_icon = FontIcon {icon = '\u{f03d}', color = color}
local gpu_temp
local gpu_graph_container


if file.exists("/usr/bin/nvidia-smi") and not file.exists("/proc/acpi/bbswitch") then
    gpu_temp = awful.widget.watch(
        "nvidia-smi --format=csv,nounits,noheader --query-gpu=temperature.gpu",
        15,
        function(widget, stdout)
            widget:set_markup(
                string.format('<span color="%s">%s°</span>', color, text.trim(stdout))
            )
        end
    )

    local gpu_graph = Graph {color = color}
    gpu_graph_container = gpu_graph.container

    local gpu_load_command = "nvidia-smi --format=csv,nounits,noheader --query-gpu=utilization.gpu"
    local gpu_load_widget = awful.widget.watch(
        gpu_load_command,
        2,
        function(widget, stdout)
            if stdout == nil or tonumber(stdout) == nil then
                return
            end
            widget:add_value(tonumber(stdout) / 100.0)
        end,
        gpu_graph
    )
end

blinky_on = true
function toggle_blinky()
    if blinky_on then
        awful.spawn({'blinky', '--off'})
    else
        awful.spawn({'blinky', '--on'})
    end
    blinky_on = not blinky_on
end

screen_lock_on = true
function toggle_screen_lock()
    if screen_lock_on then
        awful.spawn({"xautolock", "-disable"})
        awful.spawn({"xset", "s", "off"})
    else
        awful.spawn({"xautolock", "-enable"})
        awful.spawn({"xset", "s", "on"})
    end
    screen_lock_on = not screen_lock_on
end

local gpu_container

function menu_close()
    gpu_container.prevmenu:hide()
    gpu_container.prevmenu = nil
end

gpu_container = SanityContainer {
    color = color,
    widget = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        gpu_icon,
        gpu_temp,
        gpu_graph_container,
    },
    tooltip = 'GPU Usage',
    buttons = gears.table.join(
        awful.button({ }, 1, function()
            if gpu_container.prevmenu then
                menu_close()
            else
                -- open
                local menu = awful.menu({theme = {width = 200}})

                menu:add({'Monitor Config', function()
                    awful.spawn('arandr')
                    menu_close()
                end})
                
                menu:add({'Toggle Redshift', function()
                    lain.widget.contrib.redshift:toggle()
                    menu_close()
                end})

                menu:add({'Toggle Screen Lock', function()
                    toggle_screen_lock()
                    menu_close()
                end})

                if file.exists("/usr/bin/blinky") then
                    menu:add({'Toggle Blinky LEDs', function()
                        toggle_blinky()
                        menu_close()
                    end})
                end

                awful.spawn.easy_async_with_shell(
                    string.format(folder_command, wallpapers_folder),
                    function(stdout)
                        local wp_menu = {}

                        for item in stdout:gmatch("%S+") do
                            wp_menu = gears.table.join(wp_menu, {{
                                item,
                                function()
                                    local full_path = string.format("%s/%s", wallpapers_folder, item)
                                    awful.screen.connect_for_each_screen(function(s)
                                        gears.wallpaper.maximized(full_path, s)
                                    end)
                                    menu_close()
                                end
                            }})
                        end

                        menu:add({'Wallpapers', wp_menu})
                    end
                )

                if file.exists(screenlayout_folder) then
                    awful.spawn.easy_async_with_shell(
                        string.format(folder_command, screenlayout_folder),
                        function(stdout)
                            local sl_menu = {}

                            for item in stdout:gmatch("%S+") do
                                sl_menu = gears.table.join(sl_menu, {{
                                    item,
                                    function()
                                        local full_path = string.format("%s/%s", screenlayout_folder, item)
                                        awful.spawn(string.format("bash %s", full_path))
                                        menu_close()
                                    end
                                }})
                            end

                            menu:add({'Screen Layouts', sl_menu})
                        end
                    )
                end

                menu:show()
                gpu_container.prevmenu = menu
            end
        end)
    )
}
return gpu_container
