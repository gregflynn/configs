local awful = require("awful")
local naughty = require("naughty")
local beautiful = require('beautiful')
local lain = require("lain")
local markup = lain.util.markup
local dpi = beautiful.xresources.apply_dpi
local io, next, os, string, table = io, next, os, string, table

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
    current_track = nil,
    album_cover   = "/tmp/gpmcover"
}

function trim(s)
   return s:match("^%s*(.-)%s*$"):gsub('&', '&amp;')
end

function trunc(str, max_len)
    if string.len(str) > max_len then
        local feat_loc = str:find("[%(%[]")
        if feat_loc and feat_loc <= max_len then
            return trim(str:sub(1, feat_loc - 1))
        end
        return string.sub(str, 0, max_len - 3)..'...'
    end
    return str
end

function gpmdp.notification_on()
    local gpm_now = gpmdp.latest
    gpmdp.current_track = gpm_now.title

    if gpmdp.followtag then gpmdp.notification_preset.screen = awful.screen.focused() end
    awful.spawn.easy_async({"curl", gpm_now.cover_url, "-o", gpmdp.album_cover}, function(stdout)
        local old_id = nil
        if gpmdp.notification then old_id = gpmdp.notification.id end

        gpmdp.notification = naughty.notify({
            preset = gpmdp.notification_preset,
            icon = gpmdp.album_cover,
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

function gpmdp.get_now(running)
    local gpm_now = {
        running = running,
        playing = false
    }

    local filelines = gpmdp.get_lines(gpmdp.file_location)

    -- exit early if gpmdp isn't running
    if not running or not filelines then
        return gpm_now
    end

    -- parse the json file
    local json = lain.util.dkjson
    local dict, pos, err = json.decode(table.concat(filelines), 1, nil)

    -- sometimes dict doesn't parse
    if not dict then
        return gpm_now
    end

    -- pull out all them datas
    gpm_now.artist = dict.song.artist
    gpm_now.album = dict.song.album
    gpm_now.title = dict.song.title
    gpm_now.cover_url = dict.song.albumArt
    gpm_now.playing = dict.playing
    return gpm_now
end

gpmdp.widget = awful.widget.watch({"pidof", "Google Play Music Desktop Player"}, 2, function(widget, stdout)
    local gpm_now = gpmdp.get_now(stdout ~= '')
    gpmdp.latest = gpm_now

    local text = ""
    local color = beautiful.fg_minimize

    if gpm_now.running then
       if gpm_now.title then
            local title = trim(gpm_now.title)
            local artist = trim(gpm_now.artist)
            local album = trim(gpm_now.album)

            local title_short = trunc(title, 20)
            local artist_short = trunc(artist, 20)

            local title_color = beautiful.fg_focus
            local artist_color = beautiful.fg_minimize
            local icon = ""

            if gpm_now.playing then
                icon = "🎵 "
            end

            widget:set_markup(string.format(
                "%s%s %s %s",
                markup.fg.color(title_color, icon),
                markup.fg.color(title_color, title_short),
                markup.italic("by"),
                markup.fg.color(artist_color, artist_short)
            ))

            gpmdp.notification_preset.text = string.format(
                "\n%s\n%s\n%s",
                markup.fg.color(title_color, markup.big(title)),
                markup.fg.color(artist_color, markup.big(artist)),
                markup.italic(markup.big(album))
            )

            if gpmdp.notify == "on" and gpm_now.title ~= gpmdp.current_track then
                gpmdp.notification_on()
            end
        end
    else
        gpmdp.current_track = nil
    end
end)

gpmdp.widget:connect_signal("mouse::enter", gpmdp.notification_on)
gpmdp.widget:connect_signal("mouse::leave", gpmdp.notification_off)

return gpmdp
