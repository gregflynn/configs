local awful = require('awful')
local lain = require("lain")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local gears = require("gears")

local dpi = beautiful.xresources.apply_dpi
local markup = lain.util.markup

local mempie = {
    widget = wibox.widget {
        max_value = 1,
        thickness = dpi(4),
        start_angle = 0,
        bg = beautiful.colors.gray,
        colors = { beautiful.colors.blue },
        widget = wibox.container.arcchart
    },
    notification_preset = {
        title     = 'Memory Used',
        timeout   = 6
    },
}

function mempie.notification_on()
    local old_id = nil

    if mempie.notification then
        old_id = mempie.notification.id
    end

    mempie.notification = naughty.notify({
        preset = mempie.notification_preset,
        replaces_id = old_id
    })
end

mempie.memory = lain.widget.mem {
    settings = function()
        mempie.widget.value = mem_now.perc / 100
        mempie.notification_preset.text = markup.big(
            markup.fg.color(
                beautiful.colors.blue,
                string.format('%s%%', mem_now.perc)
            )
        )
    end
}

mempie.widget:buttons(gears.table.join(
    awful.button({ }, 1, function()
        mempie.notification_on()
    end)
))

mempie.container = wibox.container.margin(
    mempie.widget, dpi(3), dpi(3)
)

return mempie
