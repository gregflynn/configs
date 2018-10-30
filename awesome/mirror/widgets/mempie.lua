local lain      = require("lain")
local wibox     = require("wibox")
local beautiful = require("beautiful")

local number = require("util/number")
local Pie    = require("util/pie")
local text   = require("util/text")

local colors = beautiful.colors
local dpi    = beautiful.xresources.apply_dpi
local markup = lain.util.markup


function pi_notif_row(label, bytes, color, pct)
    return string.format(
        "%s: %s %s",
        markup.bold(text.pad(label, 5)),
        markup.fg.color(color, text.pad(number.human_bytes(bytes), 7)),
        pct and string.format("(%s%%)", pct) or ""
    )
end

local pi = Pie {
    notification_title = "Memory",
    command = "free -b | grep Mem | awk '{ print $2,$3,$4,$5,$6,$7 }'",
    parse_command = function(stdout)
        local split = text.split(stdout)
        local total_bytes = tonumber(split[1])
        local used_bytes = tonumber(split[2])
        local free_bytes = tonumber(split[3])

        local used_raw_pct = used_bytes / total_bytes
        local pct_used = number.round(used_raw_pct * 100, 1)
        local pct_free = number.round(100 * free_bytes / total_bytes, 1)

        return {
            pct = used_raw_pct,
            tooltip = string.format("Memory: %s%% Used", pct_used),
            notification_preset = {
                text = string.format(
                    "%s\n%s\n%s",
                    pi_notif_row("Free", free_bytes, colors.green, pct_free),
                    pi_notif_row("Used", used_bytes, colors.red, pct_used),
                    pi_notif_row("Total", total_bytes, colors.blue)
                )
            }
        }
    end
}

pi.container = wibox.container.margin(pi, dpi(3), dpi(3))

return pi
