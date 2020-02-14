local beautiful = require('beautiful')
local lain      = require('lain')
local wibox     = require('wibox')

local FontIcon        = require('util/fonticon')
local SanityContainer = require('util/sanitycontainer')

local colors = beautiful.colors
local battery_icons = {
    plug    = "\u{f1e6}",
    full    = "\u{f240}",
    good    = "\u{f241}",
    low     = "\u{f242}",
    caution = "\u{f243}",
    empty   = "\u{f244}",
}
local battery_colors = {
    plug    = colors.green,
    full    = colors.green,
    good    = colors.green,
    low     = colors.orange,
    caution = colors.red,
    empty   = colors.red,
}
local battery = {
    battery_enabled = false,
    font_icon = FontIcon {icon = battery_icons['empty'], color = colors.yellow},
}


function battery:get_status()
    local pct = bat_now.perc or 0

    if bat_now.ac_status == "1" and (bat_now.status == "Charging" or bat_now.status == "Full") then
        return "plug"
    end

    if     pct < 10 then return "empty"
    elseif pct < 20 then return "caution"
    elseif pct < 50 then return "low"
    elseif pct < 90 then return "good"
    end

    return "full"
end

battery.lain_widget = lain.widget.bat {
    settings = function()
        if not battery.sanitycontainer then
            return
        end

        if bat_now.perc == "N/A" then
            battery.font_icon:update(battery_icons["empty"], colors.gray)
            widget:set_markup(string.format("<span color='%s'>N/A</span>", colors.gray))
            return
        end

        local tooltip
        if bat_now.status == 'Full' then
            tooltip = 'Full'
        elseif bat_now.status == 'Charging' then
            tooltip = bat_now.time..' Until Full'
        elseif bat_now.status == 'Discharging' then
            tooltip = bat_now.time..' Until Empty'
        else
            tooltip = 'N/A'
        end
        battery.sanitycontainer:set_tooltip_color('Battery', tooltip)

        widget.visible = bat_now.perc < 100

        local status = battery:get_status()
        local color = battery_colors[status]
        battery.sanitycontainer:set_color(color)
        battery.font_icon:update(battery_icons[status], color)
        widget:set_markup(string.format(
            '<span color="%s">%s%%</span>', color, bat_now.perc
        ))
    end
}

battery.sanitycontainer = SanityContainer {
    widget = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        battery.font_icon,
        battery.lain_widget.widget
    },
    color   = colors.yellow
}

-- update the battery now that everything is setup
battery.lain_widget.update()

return battery.sanitycontainer
