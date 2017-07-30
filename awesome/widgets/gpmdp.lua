local awful = require("awful")
local naughty = require("naughty")
local beautiful = require('beautiful')
local lain = require("lain")
local markup = lain.util.markup
local dpi = beautiful.xresources.apply_dpi

local gpmdp = {
    notify        = "on",
    followtag     = false,
    file_location = os.getenv("HOME") .. "/.config/Google Play Music Desktop Player/json_store/playback.json",
    notification_preset = {
        title     = "Now playing",
        icon_size = dpi(128),
        timeout   = 6
    },
    notification  = nil,
    current_track = nil
}

function gpmdp.notification_on()
    local gpm_now = gpmdp.latest
    gpmdp.current_track = gpm_now.title

    if gpmdp.followtag then gpmdp.notification_preset.screen = awful.screen.focused() end
    awful.spawn.easy_async(string.format("curl %s -o /tmp/gpmcover.png", gpm_now.cover_url), function(stdout)
        local old_id = nil
        if gpmdp.notification then old_id = gpmdp.notification.id end

        gpmdp.notification = naughty.notify({
        preset = gpmdp.notification_preset,
        icon = "/tmp/gpmcover.png",
        replaces_id = old_id
        })
    end)
end

function gpmdp.notification_off()
    if not gpmdp.notification then return end
    naughty.destroy(gpmdp.notification)
    gpmdp.notification = nil
end

function gpmdp.get_lines(file)
    local f = io.open(file)
    if not f then return
    else f:close() end

    local lines = {}
    for line in io.lines(file) do
        lines[#lines + 1] = line
    end
    return lines
end

gpmdp.widget = awful.widget.watch("pidof 'Google Play Music Desktop Player'", 2, function(widget, stdout)
    local filelines = gpmdp.get_lines(gpmdp.file_location)
    if not filelines then return end -- GPMDP not running?

    gpm_now = { running = stdout ~= '' }

    if not next(filelines) then
        gpm_now.running = false
        gpm_now.playing = false
    else
        local json = lain.util.dkjson
        dict, pos, err = json.decode(table.concat(filelines), 1, nil)
        gpm_now.artist    = dict.song.artist
        gpm_now.album     = dict.song.album
        gpm_now.title     = dict.song.title
        gpm_now.cover_url = dict.song.albumArt
        gpm_now.playing   = dict.playing
    end
    gpmdp.latest = gpm_now

    -- customize here
    local text = ""
    local color = beautiful.fg_minimize

    if gpm_now.running then
        if gpm_now.title then
        local title = trunc(gpm_now.title, 20)
        local artist = trunc(gpm_now.artist, 20)

        text = string.format(
            "%s %s %s",
            markup.fg.color(beautiful.fg_focus, '🎵 '..title),
            markup.italic("by"),
            markup.fg.color(beautiful.fg_minimize, artist:gsub('&', '&amp;'))
        )

        gpmdp.notification_preset.text = string.format(
            "\n%s\n%s\n%s",
            markup.fg.color(beautiful.fg_focus, markup.big(gpm_now.title)),
            markup.fg.color(beautiful.fg_minimize, markup.big(gpm_now.artist:gsub('&', '&amp;'))),
            markup.italic(markup.big(gpm_now.album))
        )
        end
    end

    widget:set_markup(text)

    if gpm_now.playing then
        if gpmdp.notify == "on" and gpm_now.title ~= gpmdp.current_track then
        gpmdp.notification_on()
        end
    elseif not gpm_now.running then
        gpmdp.current_track = nil
    end
end)

gpmdp.widget:connect_signal("mouse::enter", gpmdp.notification_on)
gpmdp.widget:connect_signal("mouse::leave", gpmdp.notification_off)

return gpmdp
