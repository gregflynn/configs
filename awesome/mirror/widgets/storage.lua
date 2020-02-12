local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local vicious = require('vicious')

local text            = require('util/text')
local Pie             = require('util/pie')
local SanityContainer = require('util/sanitycontainer')
local Graph           = require('util/graph')

local colors = beautiful.colors
local color = colors.purple

local root_pie = Pie { colors = {color}, }
local boot_pie = Pie { colors = {color}, }

awful.widget.watch(
        {awful.util.shell, "-c", "df -B1 | tail -n +2 | awk '{ print $6,$5 }'"},
        5,
        function(_, stdout)
            -- stdout is all drives, "mount pct"
            local boot_pct = "?%"
            local root_pct = "?%"

            for _, df in ipairs(text.split(stdout, '\n')) do
                local dfParts = text.split(df)

                if dfParts[1] == '/boot' then
                    boot_pct = dfParts[2]
                elseif dfParts[1] == '/' then
                    root_pct = dfParts[2]
                end
            end

            root_pie:update(tonumber(string.sub(root_pct, 1, -2)) / 100)
            boot_pie:update(tonumber(string.sub(boot_pct, 1, -2)) / 100)
            update_tooltip(boot_pct, root_pct)
        end)

local disk_load_widget = Graph {color = color}
disk_load_widget.scale = true
vicious.register(disk_load_widget, vicious.widgets.dio, "${nvme0n1 total_kb}")

local container = SanityContainer {
    widget = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        root_pie,
        boot_pie,
        disk_load_widget.container
    },
    color = color
}

function update_tooltip(boot_pct, root_pct)
    local fmt = '%s: %s Used'
    local root = string.format(fmt, 'root', root_pct)
    local boot = string.format(fmt, 'boot', boot_pct)
    container:set_tooltip_color(string.format('%s\n%s', root, boot))
end

return container
