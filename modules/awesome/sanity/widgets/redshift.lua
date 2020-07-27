local Container  = require('sanity/util/container')
local DoubleWide = require('sanity/util/doublewide')
local FontIcon   = require('sanity/util/fonticon')

local redshift = require('lain.widget.contrib.redshift')


local color_on  = colors.orange
local color_off = colors.gray
local color     = redshift.active and color_on or color_off

local redshift_icon     = '嗀'
local redshift_icon_on  = ''
local redshift_icon_off = ''

local redshift_container
local redshift_font_icon = FontIcon {
    small = true,
    icon  = redshift_icon,
    color = color
}
local redshift_status_icon = FontIcon {
    small = true,
    icon  = redshift.active and redshift_icon_on or redshift_icon_off,
    color = color
}

function toggle_redshift()
    if redshift.active then
        redshift_container:set_color(color_on)
        redshift_font_icon:update(redshift_icon, color_on)
        redshift_status_icon:update(redshift_icon_on, color_on)
    else
        redshift_container:set_color(color_off)
        redshift_font_icon:update(redshift_icon, color_off)
        redshift_status_icon:update(redshift_icon_off, color_off)
    end
end

redshift_container = Container {
    color  = color,
    widget = DoubleWide {
        left_widget  = redshift_font_icon,
        right_widget = redshift_status_icon
    },
    no_tooltip = true
}

redshift:attach(redshift_container, toggle_redshift)

return redshift_container
