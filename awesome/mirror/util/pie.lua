local awful     = require('awful')
local beautiful = require("beautiful")
local gears     = require("gears")
local naughty   = require("naughty")
local wibox     = require("wibox")

local dpi = beautiful.xresources.apply_dpi


function factory(args)
    local args = args or {}

    local tooltip = awful.tooltip {}

    local Pie = awful.widget.watch(
        args.command,
        args.time or 30,
        function(widget, stdout)
            local pie_data = args.parse_command(stdout)

            tooltip:set_text(pie_data.tooltip)
            widget.value = pie_data.pct

            local preset = pie_data.notification_preset
            widget.notification_preset = {
                title = args.notification_title or preset.title,
                timeout = args.notification_timeout or preset.timeout or 6,
                text = preset.text
            }
        end,
        wibox.widget {
            max_value = 1,
            thickness = dpi(6),
            start_angle = 0,
            bg = args.bg_color or beautiful.colors.gray,
            colors = args.colors or {beautiful.colors.blue},
            widget = wibox.container.arcchart
        }
    )

    function Pie:notification_on()
        if Pie.notification_preset then
            local old_id

            if Pie.notification then
                old_id = Pie.notification.id
            end

            Pie.notification = naughty.notify({
                preset = Pie.notification_preset,
                replaces_id = old_id
            })
        end
    end

    tooltip:add_to_object(Pie)

    Pie:buttons(gears.table.join(
        awful.button({ }, 1, function()
            Pie:notification_on()
        end),
        awful.button({}, 3, function()
            if args.right_click then
                awful.spawn(args.right_click)
            end
        end)
    ))

    return Pie
end

return factory
