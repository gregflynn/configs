local lain = require("lain")
local beautiful = require("beautiful")

local memory = lain.widget.mem {
    settings = function()
        widget:set_markup(string.format(
            '<span color="%s">🐏 %d%%</span>',
            beautiful.fg_minimize,
            mem_now.perc
        ))
    end
}

return memory
