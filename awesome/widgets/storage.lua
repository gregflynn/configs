local lain = require("lain")
local beautiful = require("beautiful")
local wibox = require("wibox")
local naughty = require("naughty")
local awful = require("awful")

local dpi = beautiful.xresources.apply_dpi
local markup = lain.util.markup

local storage = {
    mem_pct = 0,
    root_pct = 0,
    boot_pct = 0,
    mem_bar = wibox.widget {
        max_value        = 100,
        widget           = wibox.widget.progressbar,
        color            = beautiful.fg_minimize,
        background_color = beautiful.fg_normal
    },
    root_bar = wibox.widget {
        max_value        = 100,
        widget           = wibox.widget.progressbar,
        color            = beautiful.fg_urgent,
        background_color = beautiful.fg_normal
    },
    boot_bar = wibox.widget {
        max_value        = 100,
        widget           = wibox.widget.progressbar,
        color            = beautiful.fg_focus,
        background_color = beautiful.fg_normal
    },
    notification  = nil,
    notification_preset = {
        title     = "Storage Usage",
        icon_size = dpi(128),
        timeout   = 6,
        icon      = "/usr/share/icons/elementary/devices/128/drive-harddisk.svg"
    }
}

function storage.notification_on()
    storage.notification_preset.screen = awful.screen.focused()
    local old_id = nil
    if storage.notification then old_id = storage.notification.id end

    -- update notification text
    storage.notification_preset.text = markup.big(string.format(
        "\n%s\n%s\n%s",
        markup.fg.color(
            beautiful.fg_minimize,
            string.format("Memory: %s%%", storage.mem_pct)
        ),
        markup.fg.color(
            beautiful.fg_urgent,
            string.format("/     : %s%%", storage.root_pct)
        ),
        markup.fg.color(
            beautiful.fg_focus,
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

storage.mem_wid = wibox.widget {
    storage.mem_bar,
    forced_width  = dpi(5),
    direction     = 'east',
    layout        = wibox.container.rotate
}

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

storage.memory = lain.widget.mem {
    settings = function()
        storage.mem_pct = mem_now.perc
        storage.mem_bar:set_value(mem_now.perc)
    end
}

storage.disk = lain.widget.fs {
    notify   = "off",
    settings = function()
        storage.root_pct = tonumber(fs_info['/ used_p'])
        storage.boot_pct = tonumber(fs_info['/boot used_p'])
        storage.root_bar:set_value(storage.root_pct)
        storage.boot_bar:set_value(storage.boot_pct)
    end
}

storage.container = {
    layout = wibox.layout.fixed.horizontal,
    wibox.container.margin(storage.mem_wid,   dpi(0), dpi(3), dpi(4), dpi(4)),
    wibox.container.margin(storage.root_wid,  dpi(0), dpi(3), dpi(4), dpi(4)),
    wibox.container.margin(storage.boot_wid,  dpi(0), dpi(10), dpi(4), dpi(4))
}

storage.mem_wid:connect_signal(
    "mouse::enter", storage.notification_on
)
storage.mem_wid:connect_signal(
    "mouse::leave", storage.notification_off
)
storage.root_wid:connect_signal(
    "mouse::enter", storage.notification_on
)
storage.root_wid:connect_signal(
    "mouse::leave", storage.notification_off
)
storage.boot_wid:connect_signal(
    "mouse::enter", storage.notification_on
)
storage.boot_wid:connect_signal(
    "mouse::leave", storage.notification_off
)

return storage
