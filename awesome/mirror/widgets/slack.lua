local awful     = require('awful')
local beautiful = require('beautiful')
local gears     = require('gears')

local text            = require('util/text')
local FontIcon        = require('util/fonticon')
local SanityContainer = require('util/sanitycontainer')

local colors = beautiful.colors


local slack_icon_hex = '\u{f198}'
local slack_icon = FontIcon { icon = slack_icon_hex, color = colors.red }

local slack_container = SanityContainer {
    widget = slack_icon,
    tooltip = 'Slack',
    color = colors.red,
    buttons = gears.table.join(
        awful.button({}, 1, function()
            awful.spawn('slack')
        end)
    )
}

function get_slack_client()
    for _, c in ipairs(client.get()) do
        if c.class == 'Slack' then
            return c
        end
    end
end

function set_slack_color(color)
    slack_container:set_color(color)
    slack_icon:update(slack_icon_hex, color)
end

local timer
function slack_update()
    local slack_client = get_slack_client()

    function hide_slack()
        set_slack_color(colors.gray)
        slack_container:hide()
    end

    if not slack_client then
        hide_slack()
    else
        if not slack_client.name then
            hide_slack()
        end
        slack_container:show()
        local name_parts = text.split(slack_client.name, '|')
        local title = text.trim(name_parts[2])
        local slack_notification = title:sub(1, 1)

        if slack_notification == '!' then
            set_slack_color(colors.red)
        elseif slack_notification == '*' then
            set_slack_color(colors.blue)
        else
            set_slack_color(colors.white)
        end
    end

    timer.timeout = 5
    timer:again()
    return true
end
timer = gears.timer.weak_start_new(5, slack_update)
timer:emit_signal('timeout')

return slack_container
