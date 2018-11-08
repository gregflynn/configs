local awful     = require("awful")
local beautiful = require("beautiful")
local gears     = require("gears")
local wibox     = require("wibox")
local lain      = require("lain")

local Arrow    = require("util/arrow")
local display  = require("util/display")
local FontIcon = require("util/fonticon")
local text     = require("util/text")
local colors   = beautiful.colors


local function listupdate_tags(w, buttons, label, data, tags)
    w:reset()
    local prev_color = colors.background

    for idx, tag in ipairs(tags) do
        local tn = tag.name
        local cache = data[tag]
        local arr

        if cache then
            arr = cache.arr
        else
            local widget
            if tn:len() == 3 then
                widget = FontIcon { icon = tn }
            else
                widget = wibox.widget.textbox()
            end

            arr = Arrow { widget = widget, right = true, no_right = idx ~= #tags }

            data[tag] = {
                arr = arr,
            }
        end

        local title, bg = label(tag, arr.widget)
        if tn:len() == 3 then
            local color_side = text.split(title, "color")[2]
            if color_side then
                local fg_color = text.select(color_side, "'")
                arr.widget:update(tn, fg_color)
            else
                arr.widget:update(tn, colors.white)
            end
        else
            arr.widget:set_markup_silently(title)
        end

        local arr_color = bg or colors.background
        arr:update(arr_color, colors.background, prev_color)
        prev_color = arr_color

        arr:buttons(awful.widget.common.create_buttons(buttons, tag))
        w:add(arr)
    end
end

local function factory(args)
    local screen  = args.screen
    local taglist = args.taglist

    local screen_type = display.screen_type(screen)

    awful.tag(
        taglist, screen,
        {
            awful.layout.suit.floating,
            screen_type == 'ultrawide' and lain.layout.centerwork or awful.layout.suit.tile,
            screen_type == 'ultrawide' and lain.layout.centerwork or awful.layout.suit.fair,
            awful.layout.suit.floating,
            awful.layout.suit.floating
        }
    )

    return awful.widget.taglist(
        screen,
        awful.widget.taglist.filter.all,
        gears.table.join(
            awful.button({ }, 1, function(t) t:view_only() end)
        ),
        nil,
        listupdate_tags
    )
end

return factory
