local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require('beautiful')
local lain = require("lain")
local markup = lain.util.markup
local dpi = beautiful.xresources.apply_dpi
local io, next, os, string, table = io, next, os, string, table

local gpmdp_icon_loc = "/usr/share/pixmaps/gpmdp.png"
local gpmdp_album_art_fmt = "/tmp/gpmcover-%s"

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
    current_album_art = nil,
    icon = wibox.widget {
        image  = gpmdp_icon_loc,
        resize = true,
        widget = wibox.widget.imagebox
    }
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
    local new_album_art = string.format(gpmdp_album_art_fmt, math.random(0, 3894732897))
    local gpm_now = gpmdp.latest
    gpmdp.current_track = gpm_now.title

    if gpmdp.followtag then
        gpmdp.notification_preset.screen = awful.screen.focused()
    end

    awful.spawn.easy_async({"curl", gpm_now.cover_url, "-o", new_album_art}, function(stdout)
        local old_id = nil
        gpmdp.icon.image = new_album_art

        if gpmdp.notification then
            old_id = gpmdp.notification.id
        end

        gpmdp.notification = naughty.notify({
            preset = gpmdp.notification_preset,
            icon = new_album_art,
            replaces_id = old_id
        })

        -- clean up album art
        if gpmdp.current_album_art then
            os.remove(gpmdp.current_album_art)
        end
        gpmdp.current_album_art = new_album_art
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

    if gpm_now.running then
       if gpm_now.title then
            local title = trim(gpm_now.title)
            local artist = trim(gpm_now.artist)
            local album = trim(gpm_now.album)

            local title_color = beautiful.colors.background
            local artist_color = beautiful.colors.background
            local title_text = markup.italic("%s").." / %s"

            if not gpm_now.playing then
                title_color = beautiful.colors.grey
                artist_color = beautiful.colors.grey
                gpmdp.icon.image = gpmdp_icon_loc
            else
                gpmdp.icon.image = gpmdp.current_album_art
            end

            widget:set_markup(string.format(
                title_text,
                markup.fg.color(title_color, trunc(title, 20)),
                markup.fg.color(artist_color, trunc(artist, 20))
            ))

            gpmdp.notification_preset.text = string.format(
                "\n%s\n%s\n%s",
                markup.fg.color(beautiful.colors.white, markup.big(title)),
                markup.fg.color(beautiful.colors.purple, markup.big(artist)),
                markup.fg.color(beautiful.colors.blue, markup.italic(markup.big(album)))
            )

            if gpmdp.notify == "on" and gpm_now.title ~= gpmdp.current_track then
                gpmdp.notification_on()
            end
        end
    else
        widget:set_markup('')
        gpmdp.current_track = nil
    end
end)

local buttons = gears.table.join(
    awful.button({ }, 1, function()
        awful.spawn("gpmdp")
    end),
    awful.button({ }, 3, function()
        gpmdp.notification_on()
    end)
)

gpmdp.widget:buttons(buttons)
gpmdp.icon:buttons(buttons)

gpmdp.container = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    wibox.container.margin(gpmdp.icon,    dpi(3),  dpi(3)),
    wibox.container.margin(gpmdp.widget,  dpi(0), dpi(0))
}

return gpmdp
