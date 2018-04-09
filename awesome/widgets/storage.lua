local lain = require("lain")
local beautiful = require("beautiful")
local wibox = require("wibox")
local naughty = require("naughty")
local awful = require("awful")
local gears = require("gears")

local dpi = beautiful.xresources.apply_dpi
local markup = lain.util.markup

local storage = {
    mem_pct = 0,
    root_pct = 0,
    boot_pct = 0,
    root_bar = wibox.widget {
        max_value        = 100,
        widget           = wibox.widget.progressbar,
        color            = beautiful.colors.purple,
        background_color = beautiful.colors.grey
    },
    boot_bar = wibox.widget {
        max_value        = 100,
        widget           = wibox.widget.progressbar,
        color            = beautiful.colors.green,
        background_color = beautiful.colors.grey
    },
    notification  = nil,
    notification_preset = {
        title     = "Storage Usage",
        timeout   = 6,
    }
}

function storage.notification_on()
    storage.notification_preset.screen = awful.screen.focused()
    local old_id = nil
    if storage.notification then old_id = storage.notification.id end

    -- update notification text
    storage.notification_preset.text = markup.big(string.format(
        "%s\n%s",
        markup.fg.color(
            beautiful.colors.purple,
            string.format("/     : %s%%", storage.root_pct)
        ),
        markup.fg.color(
            beautiful.colors.green,
            string.format("/boot : %s%%", storage.boot_pct)
        )
    ))

    storage.notification = naughty.notify({
        preset = storage.notification_preset,
        replaces_id = old_id
    })
end

function storage.notification_off()
    if not storage.notification then return end
    naughty.destroy(storage.notification)
    storage.notification = nil
end

storage.root_wid = wibox.widget {
    storage.root_bar,
    forced_width  = dpi(5),
    direction     = 'east',
    layout        = wibox.container.rotate
}

storage.boot_wid = wibox.widget {
    storage.boot_bar,
    forced_width  = dpi(5),
    direction     = 'east',
    layout        = wibox.container.rotate
}

storage.disk = lain.widget.fs {
    notify   = "off",
    settings = function()
        storage.root_pct = tonumber(fs_now['/'].percentage)
        storage.boot_pct = tonumber(fs_now['/boot'].percentage)
        storage.root_bar:set_value(storage.root_pct)
        storage.boot_bar:set_value(storage.boot_pct)
    end
}

storage.container = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    wibox.container.margin(storage.root_wid, dpi(0), dpi(3)),
    wibox.container.margin(storage.boot_wid, dpi(0), dpi(5)),
    buttons = gears.table.join(
        awful.button({ }, 1, function()
            storage.notification_on()
        end)
    )
}

return storage
