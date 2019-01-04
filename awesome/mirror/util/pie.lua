local awful     = require('awful')
local beautiful = require("beautiful")
local gears     = require("gears")
local naughty   = require("naughty")
local wibox     = require("wibox")

local number   = require("util/number")

local colors = beautiful.colors
local dpi    = beautiful.xresources.apply_dpi


function factory(args)
    local args = args or {}

    local command              = args.command
    local parse_command        = args.parse_command
    local time                 = args.time or 30
    local bg_color             = args.bg_color or colors.gray
    local pie_colors           = args.colors or {beautiful.colors.blue }
    local thickness            = args.thickness or 5
    local notification_title   = args.notification_title
    local notification_timeout = args.notification_timeout
    local right_click          = args.right_click
    local max_value            = args.max_value or 1

    local tooltip = awful.tooltip {}

    local Pie = awful.widget.watch(
        { awful.util.shell, "-c", command },
        time,
        function(widget, stdout)
            local pie_data = parse_command(stdout)
            local tooltip_pct = pie_data.used_pct
            if not tooltip_pct then
                tooltip_pct = pie_data.values[1]
            end

            tooltip:set_text(string.format("%s: %s%% Used",
                notification_title,
                number.round(tooltip_pct * 100, 1)
            ))
            widget.values = pie_data.values

            local preset = pie_data.notification_preset
            widget.notification_preset = {
                title = notification_title or preset.title,
                timeout = notification_timeout or preset.timeout or 6,
                text = preset.text
            }
        end,
        wibox.widget {
            max_value = max_value,
            thickness = dpi(thickness),
            start_angle = (2 * math.pi) * 3 / 4,
            bg = bg_color,
            colors = pie_colors,
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
                awful.spawn(right_click)
            end
        end)
    ))

    return Pie
end

return factory
