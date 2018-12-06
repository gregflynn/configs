local awful     = require("awful")
local beautiful = require("beautiful")

local lain     = require("lain")
local FontIcon = require("util/fonticon")
local colors   = beautiful.colors


local active_icon   = "\u{f800}"
local inactive_icon = "\u{f800}"
local redshift      = FontIcon()

local tooltip = awful.tooltip {
    objects = {redshift},
    text    = "redshift"
}

lain.widget.contrib.redshift:attach(
    redshift,
    function (active)
        if active then
            tooltip.text = "Redshift: Active"
            redshift:update(active_icon, colors.background)
        else
            tooltip.text = "Redshift: Inctive"
            redshift:update(inactive_icon, colors.red)
        end
    end
)

return redshift
