local beautiful = require('beautiful')
local wibox     = require('wibox')

local Expand          = require('util/expand')
local SanityContainer = require('util/sanitycontainer')


local systray = Expand {
    font_icon = "\u{fae2}",
    widget = wibox.widget.systray()
}

return SanityContainer {
    widget = systray,
    color = beautiful.colors.yellow,
    tooltip = 'Systray'
}
