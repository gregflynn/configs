local Container  = require('sanity/util/container')
local FontIcon   = require('sanity/util/fonticon')

local redshift = require('lain.widget.contrib.redshift')


local color_on  = colors.white
local color_off = colors.red
local color     = redshift.active and color_on or color_off

local redshift_icon     = '嗀'

local redshift_container
local redshift_font_icon = FontIcon {
    small = true,
    icon  = redshift_icon,
    color = color
}

function toggle_redshift()
    if redshift.active then
        redshift_font_icon:update(redshift_icon, color_on)
    else
        redshift_font_icon:update(redshift_icon, color_off)
    end
end

redshift_container = Container {
    color  = color,
    widget = redshift_font_icon,
    no_tooltip = true
}

redshift.attach(redshift_container, toggle_redshift)

return redshift_container
