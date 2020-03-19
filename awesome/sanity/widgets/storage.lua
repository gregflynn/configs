local string = string

local beautiful = require('beautiful')
local gears     = require('gears')
local vicious   = require('vicious')
local Container = require('sanity/util/container')
local Graph     = require('sanity/util/graph')
local display   = require('sanity/util/display')
local icon      = require('sanity/util/icon')
local text      = require('sanity/util/text')

local button = require('awful.button')
local menu   = require('awful.menu')
local util   = require('awful.util')
local spawn  = require('awful.spawn')
local watch  = require('awful.widget.watch')
local markup = require('lain.util.markup')
local widget = require('wibox.widget')
local fixed  = require('wibox.layout.fixed')

local color       = colors.purple
local storage_cmd = 'df -B1 | tail -n +2 | awk \'{ print $6,$5 }\''

local storage_container
local storage_menu = menu({
    theme = { width = 100 },
    items = {
        {'Root', function()
            spawn({'xdg-open', '/'})
        end, icon.get_path('devices', 'drive-harddisk')},
        {'Home', function()
            spawn({'xdg-open', beautiful.home})
        end, icon.get_path('places', 'user-home')},
    }
})

local initial_pct = '?%'

local root_pct_textbox = watch({util.shell, '-c', storage_cmd}, 60, function(w, stdout)
    -- stdout is all drives, 'mount pct'
    local lines    = text.split(stdout, '\n')
    local boot_pct = initial_pct
    local root_pct = initial_pct

    for i=1, #lines do
        local dfParts = text.split(lines[i])

        if dfParts[1] == '/boot' then
            boot_pct = dfParts[2]
        elseif dfParts[1] == '/' then
            root_pct = dfParts[2]
        end
    end

    w:set_markup(markup.fg.color(color, root_pct))
    storage_container:set_tooltip_color(' Storage ', string.format(
        ' root: %s Used \n boot: %s Used ', root_pct, boot_pct
    ))
end)

local disk_load_widget = Graph {color = color, scale = true}
vicious.register(disk_load_widget, vicious.widgets.dio, '${nvme0n1 total_kb}', graph_interval)

storage_container = Container {
    widget  = widget {
        layout = fixed.vertical,
        display.center(root_pct_textbox),
        disk_load_widget.container,
    },
    color   = color,
    buttons = gears.table.join(
        button({}, 1, function() storage_menu:toggle() end),
        button({}, 3, function() storage_menu:toggle() end)
    ),
}

return storage_container
