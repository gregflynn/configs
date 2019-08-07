local os, string = os, string

local beautiful = require('beautiful')
local naughty   = require('naughty')

local lain = require('lain')

local music = require('util/music')

local markup = lain.util.markup
local dpi    = beautiful.xresources.apply_dpi
local colors = beautiful.colors


local gpmdp = {
    notification_preset = {
        title     = "Now playing",
        icon_size = dpi(128),
        timeout   = 6
    },
    notification  = nil,
    current_track = nil,
    current_album_art = nil,
    first_run = true
}

function gpmdp.notification_on(current)
    if gpmdp.first_run then
        gpmdp.first_run = false
        return
    end

    gpmdp.current_track = current.title
    music.get_album_art(current, function(album_art_path)
        local old_id
    
        if gpmdp.notification then
            old_id = gpmdp.notification.id
        end
    
        gpmdp.notification = naughty.notify({
            preset = gpmdp.notification_preset,
            icon = album_art_path,
            replaces_id = old_id
        })
    
        -- clean up album art
        if gpmdp.current_album_art then
            os.remove(gpmdp.current_album_art)
        end
        gpmdp.current_album_art = album_art_path
    end)
end

function gpmdp.notification_off()
    if not gpmdp.notification then return end
    naughty.destroy(gpmdp.notification)
    gpmdp.notification = nil
end

function gpmdp.get_tooltip(current)
    return string.format(
        "%s\nBy: %s\nFrom: %s",
        markup.italic(markup.fg.color(colors.white, current.title)),
        markup.fg.color(colors.blue, current.artist),
        markup.fg.color(colors.purple, markup.italic(current.album))
    )
end

function gpmdp.update_notification(current)
    gpmdp.notification_preset.text = string.format(
        "\n%s\n%s\n%s",
        markup.fg.color(colors.white, markup.italic(markup.big(current.title))),
        markup.fg.color(colors.blue, markup.big(current.artist)),
        markup.fg.color(colors.purple, markup.italic(markup.big(current.album)))
    )

    if current.title ~= gpmdp.current_track then
        gpmdp.notification_on(current)
    end
end

return gpmdp
