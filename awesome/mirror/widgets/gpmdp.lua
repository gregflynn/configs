local io, os, string, table = io, os, string, table

local awful     = require("awful")
local beautiful = require("beautiful")
local gears     = require("gears")
local naughty   = require("naughty")
local wibox     = require("wibox")
local lain      = require("lain")

local text     = require("util/text")
local FontIcon = require("util/fonticon")

local markup = lain.util.markup
local dpi    = beautiful.xresources.apply_dpi
local colors = beautiful.colors


local gpmdp_album_art_fmt = "/tmp/gpmcover-%s"
local gpmdp_json = beautiful.home.."/.config/Google Play Music Desktop Player/json_store/playback.json"
local gpmdp_default_icon = "\u{f001}"

local gpmdp = {
    notify        = "on",
    file_location = gpmdp_json,
    notification_preset = {
        title     = "Now playing",
        icon_size = dpi(128),
        timeout   = 6
    },
    notification  = nil,
    current_track = nil,
    current_album_art = nil,
    font_icon = FontIcon {icon = gpmdp_default_icon, color = colors.background},
    running_counter = 0
}

local tooltip = awful.tooltip {}

function trunc(str, max_len)
    return text.trunc(str, max_len, '(', true)
end

function gpmdp.notification_on()
    local new_album_art = string.format(gpmdp_album_art_fmt, math.random(0, 3894732897))
    local gpm_now = gpmdp.latest
    gpmdp.current_track = gpm_now.title

    awful.spawn.easy_async({"curl", gpm_now.cover_url, "-o", new_album_art}, function()
        local old_id

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

function gpmdp.get_now()
    local gpm_now = { playing = false }
    local filelines = gpmdp.get_lines(gpmdp.file_location)

    -- exit early if gpmdp isn't running
    if not filelines then
        return gpm_now
    end

    -- parse the json file
    local json = lain.util.dkjson
    local dict, _, _ = json.decode(table.concat(filelines), 1, nil)

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

function gpmdp.render(widget, title, artist, album, is_playing)
    local font_icon = gpmdp_default_icon
    local title_color = colors.background

    if not is_playing then
        font_icon = "\u{f04c}"
        title_color = colors.gray
    end

    -- update wibar display
    gpmdp.font_icon:update(font_icon, colors.background)
    widget:set_markup(string.format(
        markup.italic("%s "),
        markup.fg.color(title_color, trunc(title, 30))
    ))

    -- update tooltip
    tooltip.markup = string.format(
        "%s\nBy: %s\nFrom: %s",
        markup.italic(markup.fg.color(colors.white, title)),
        markup.fg.color(colors.blue, artist),
        markup.fg.color(colors.purple, markup.italic(album))
    )

    -- update notification display
    gpmdp.notification_preset.text = string.format(
        "\n%s\n%s\n%s",
        markup.fg.color(colors.white, markup.italic(markup.big(title))),
        markup.fg.color(colors.blue, markup.big(artist)),
        markup.fg.color(colors.purple, markup.italic(markup.big(album)))
    )
end

function gpmdp.maybe_not_running(widget)
    gpmdp.running_counter = gpmdp.running_counter + 1
    if gpmdp.running_counter > 5 then
        gpmdp.font_icon:update(gpmdp_default_icon, colors.background)
        widget:set_markup("")
        tooltip.text = "Music"
        gpmdp.current_track = nil
    end
end

gpmdp.widget = awful.widget.watch(
    {"pidof", "Google Play Music Desktop Player"}, 2,
    function(widget, stdout)
        local is_running = stdout ~= ''

        if not is_running then
            gpmdp.maybe_not_running(widget)
            return
        end

        local gpm_now = gpmdp.get_now()
        gpmdp.latest = gpm_now

        if gpm_now.title then
            gpmdp.running_counter = 0

            local title = text.trim(gpm_now.title)
            local artist = text.trim(gpm_now.artist)
            local album = text.trim(gpm_now.album)

            gpmdp.render(widget, title, artist, album, gpm_now.playing)

            if gpmdp.notify == "on" and gpm_now.title ~= gpmdp.current_track then
                gpmdp.notification_on()
            end
        else
            gpmdp.maybe_not_running(widget)
        end
    end
)

local buttons = gears.table.join(
    awful.button({ }, 1, function()
        if gpmdp.current_track ~= nil then
            gpmdp.notification_on()
        else
            awful.spawn("gpmdp")
        end
    end)
)

gpmdp.font_icon:buttons(buttons)
gpmdp.widget:buttons(buttons)

local container = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    gpmdp.font_icon,
    wibox.container.margin(gpmdp.widget, dpi(3))
}
tooltip:add_to_object(container)

return container
