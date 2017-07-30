local lain = require("lain")
local beautiful = require("beautiful")

local diskusage = lain.widget.fs {
    notify   = "off",
    settings = function()
        widget:set_markup(string.format('💾 %d%%', fs_info['/ used_p']))
    end,
    notification_preset = {
        font = 'Hack',
        fg   = beautiful.fg_normal,
        bg   = beautiful.bg_normal
    }
}

return diskusage
