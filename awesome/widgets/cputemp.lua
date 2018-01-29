local awful = require("awful")
local beautiful = require("beautiful")

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

return cputemp
