local awful = require("awful")
local beautiful = require("beautiful")

local cputemp = {
    enabled = false
}

cputemp.widget = awful.widget.watch(
    "sensors",
    15,
    function(widget, stdout)
        local package0 = stdout:match("Package id 0:  %p(%d%d%p%d)")

        if package0 then
            cputemp.enabled = true
            widget:set_markup(
                string.format(
                    '<span color="%s">🌡️ %s°C</span>',
                    beautiful.fg_minimize,
                    package0
                )
            )
        else
            cputemp.enabled = false
        end
    end
)

return cputemp
