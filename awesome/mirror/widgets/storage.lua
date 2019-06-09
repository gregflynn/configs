local beautiful = require("beautiful")
local lain      = require("lain")
local wibox     = require("wibox")

local number   = require("util/number")
local Pie      = require("util/pie")
local text     = require("util/text")

local colors = beautiful.colors
local dpi    = beautiful.xresources.apply_dpi
local markup = lain.util.markup


local function create_storage_command(grep)
    return string.format("df -B1 %s | tail -n 1 | awk '{ print $2,$3,$4 }'", grep)
end

local function notif_row(label, bytes, color, pct)
    return string.format(
        "%s: %s %s",
        markup.bold(text.pad(label, 6)),
        markup.fg.color(color, text.pad(number.human_bytes(bytes), 7)),
        pct and string.format("(%s%%)", pct) or ""
    )
end

local function parse_command(stdout)
    local split       = text.split(stdout)
    local total_bytes = tonumber(split[1])
    local used_bytes  = tonumber(split[2])
    local free_bytes  = tonumber(split[3])

    local used_raw_pct = used_bytes / total_bytes
    local pct_used     = number.round(used_raw_pct * 100, 1)
    local pct_free     = number.round(100 * free_bytes / total_bytes, 1)
    return {
        values              = {used_raw_pct},
        notification_preset = {
            text = string.format(
                "%s\n%s\n%s",
                notif_row("Free", free_bytes, colors.green, pct_free),
                notif_row("Used", used_bytes, colors.red, pct_used),
                notif_row("Total", total_bytes, colors.blue)
            )
        }
    }
end

--local boot_pie = Pie {
--    notification_title = "boot",
--    command = create_storage_command("/boot"),
--    parse_command = parse_command,
--    colors = {colors.green },
--    bg_color = colors.background,
--}

local root_pie = Pie {
    notification_title = "root",
    command = create_storage_command("/"),
    parse_command = parse_command,
    colors = {colors.yellow},
    bg_color = colors.background,
}

return wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    wibox.container.margin(root_pie, dpi(2), dpi(2), dpi(2), dpi(2)),
--    wibox.container.margin(boot_pie, dpi(2), dpi(2), dpi(2), dpi(2)),
}
