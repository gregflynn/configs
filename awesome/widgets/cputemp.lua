local awful     = require("awful")
local beautiful = require("beautiful")
local wibox     = require("wibox")
local dpi       = beautiful.xresources.apply_dpi

local cputemp = {
    enabled = true
}

cputemp.widget = awful.widget.watch(
    "sensors",
    15,
    function(widget, stdout)
        local temp = stdout:match("Package id 0:%s+%p(%d+%p%d)")
        if not temp then
            temp = stdout:match("temp1:%s+%p(%d+%p%d)")
        end

        if temp then
            cputemp.enabled = true
            widget:set_markup(
                string.format(
                    '<span color="%s">%s°C</span>',
                    beautiful.colors.blue,
                    math.floor(temp)
                )
            )
        else
            cputemp.enabled = false
        end
    end
)

if cputemp.enabled then
    cputemp.container = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        wibox.container.margin(cputemp.widget, dpi(0), dpi(2))
    }
else
    cputemp.container = nil
end

return cputemp
