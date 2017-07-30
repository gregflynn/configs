local awful = require("awful")
local beautiful = require("beautiful")

local cputemp = awful.widget.watch("sensors", 15, function(widget, stdout)
    local package0 = stdout:match("Package id 0:  %p(%d%d%p%d)")
    widget:set_markup(string.format('<span color="%s">🌡️ %s°C</span>', beautiful.fg_minimize, package0))
end)

return cputemp
