local beautiful = require('beautiful')
local wibox     = require('wibox')

local lain = require('lain')

local number          = require('util/number')
local text            = require('util/text')
local FontIcon        = require('util/fonticon')
local Pie             = require('util/pie')
local SanityContainer = require('util/sanitycontainer')

local colors = beautiful.colors
local dpi    = beautiful.xresources.apply_dpi
local markup = lain.util.markup


local color = colors.purple

local function create_storage_command(grep)
    return string.format("df -B1 %s | tail -n 1 | awk '{ print $2,$3,$4 }'", grep)
end

local function notif_row(label, bytes, color, pct)
    return string.format(
        '%s: %s %s',
        markup.bold(text.pad(label, 6)),
        markup.fg.color(color, text.pad(number.human_bytes(bytes), 7)),
        pct and string.format("(%s%%)", pct) or ""
    )
end

local disks = {
    ['root'] = 0,
    ['boot'] = 0,
}

local function parse_command(stdout, disk)
    local split       = text.split(stdout)
    local total_bytes = tonumber(split[1])
    local used_bytes  = tonumber(split[2])
    local free_bytes  = tonumber(split[3])

    local used_raw_pct = used_bytes / total_bytes
    local pct_used     = number.round(used_raw_pct * 100, 1)
    local pct_free     = number.round(100 * free_bytes / total_bytes, 1)

    disks[disk] = used_raw_pct
    update_tooltip()

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

local boot_pie = Pie {
   notification_title = "boot",
   command = create_storage_command("/boot"),
   parse_command = function(stdout) return parse_command(stdout, 'boot') end,
   colors = {color},
   bg_color = colors.background,
}

local root_pie = Pie {
    notification_title = "root",
    command = create_storage_command("/"),
    parse_command = function(stdout) return parse_command(stdout, 'root') end,
    colors = {color},
    bg_color = colors.background,
}

local container = SanityContainer {
    widget = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        FontIcon {icon = '\u{f7c9}', color = color},
        root_pie.container,
        boot_pie.container
    },
    color = color
}

function update_tooltip()
    local fmt = '%s: %s%% Used'
    local root = string.format(fmt, 'root', number.round(disks['root'] * 100, 1))
    local boot = string.format(fmt, 'boot', number.round(disks['boot'] * 100, 1))
    container:set_tooltip_color(string.format('%s\n%s', root, boot))
end

return container
