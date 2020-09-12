local Container = require('sanity/util/container')
local DoubleWide = require('sanity/util/doublewide')
local FontIcon   = require('sanity/util/fonticon')
local Pie        = require('sanity/util/pie')

local util   = require('awful.util')
local watch  = require('awful.widget.watch')

local color       = colors.purple
local storage_cmd = "df -B1 | awk '{ print $6,$5 }' | grep '/ ' | tr -d '%' | tr -d '/ '"
local storage_pie = Pie {color = color}

watch({util.shell, '-c', storage_cmd}, 60, function(_, stdout)
    storage_pie:update((tonumber(stdout) or 0) / 100)
end)

return Container {
    widget = DoubleWide {
        left_widget = FontIcon {icon = '', color = color, small = true},
        right_widget = storage_pie,
    },
    color   = color,
    no_tooltip = true
}
