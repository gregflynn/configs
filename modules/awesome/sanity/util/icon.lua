local string = string

local imagebox = require('wibox.widget.imagebox')

-- /usr/share/icons/elementary/apps/48/
local base_path_fmt = '/usr/share/icons/%s/%s/%s/%s.svg'
local icon_theme    = 'elementary'
local default_size  = 48

local icon = {}

function icon.get_path(category, name, size)
    local s = size or default_size
    return string.format(base_path_fmt, icon_theme, category, s, name)
end

function icon.get_icon(category, name, size)
    return imagebox(
        icon.get_path(category, name, size),
        true
    )
end

return icon
