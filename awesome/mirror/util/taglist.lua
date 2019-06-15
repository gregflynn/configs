local awful     = require("awful")
local beautiful = require("beautiful")
local gears     = require("gears")
local wibox     = require("wibox")
local lain      = require("lain")

local display  = require("util/display")
local FontIcon = require("util/fonticon")
local text     = require("util/text")
local SanityContainer = require('util/sanitycontainer')

local colors   = beautiful.colors
local dpi      = beautiful.xresources.apply_dpi


local taglist   = {"\u{f303}", "\u{f674}", "\u{e7a2}", "\u{e780}", "\u{f1d8}"}
local fg_colors = {colors.blue,       colors.green,      colors.yellow,     colors.red,   colors.orange}
local not_selected_color = colors.gray

local function listupdate_tags(tag_container, buttons, label, data, tags)
    tag_container:reset()

    for idx, tag in ipairs(tags) do
        local tn = tag.name
        local cache = data[tag]
        local container, widget

        if cache then
            container = cache.c
            widget    = cache.w
        else
            if tn:len() == 3 then
                widget = FontIcon { icon = tn }
            else
                widget = wibox.widget.textbox()
            end

            container = SanityContainer {
                widget = widget,
                buttons = awful.widget.common.create_buttons(buttons, tag),
                left = true,
                no_tooltip = true
            }

            data[tag] = {
                c = container,
                w = widget
            }
        end

        local title, bg = label(tag, widget)
        local is_selected = text.split(title, "color")[2]
        local fg_color = fg_colors[idx]

        if tn:len() == 3 then
            if is_selected then
                -- selected
                widget:update(tn, fg_color)
            else
                -- not selected
                widget:update(tn, not_selected_color)
            end
        else
            widget:set_markup_silently(title)
        end

        if is_selected then
            container:set_color(fg_color)
        else
            container:set_color(not_selected_color)
        end

        tag_container:add(container)
    end
end

local function create_tag_keys(idx, override)
    local tag_name = taglist[idx]
    local key = '#'..(idx + 9)
    if override then
        key = '#'..(override + 9)
    end

    return gears.table.join(
        globalkeys,
        awful.key(
            {modkey}, key, function()
                local screen = awful.screen.focused()
                local tag = screen.tags[idx]
                if tag then
                    tag:view_only()
                end
            end,
            {description = "View "..tag_name, group = "tag"}
        ),
        awful.key(
            {modkey, "Control"}, key, function()
                local screen = awful.screen.focused()
                local tag = screen.tags[idx]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end,
            {description = "Toggle " .. tag_name, group = "tag"}
        ),
        awful.key(
            {modkey, "Shift"}, key, function()
                if client.focus then
                    local tag = client.focus.screen.tags[idx]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            {description = "Move Window to " .. tag_name, group = "tag"}
        )
    )
end

local function factory(args)
    -- crazy hack to generator taglist keys
    if args.keys then
        local globalkeys = gears.table.join(
            awful.key(
                {modkey}, "Left", awful.tag.viewprev,
                {description = "Previous Tag", group = "tag"}
            ),
            awful.key(
                {modkey}, "Right", awful.tag.viewnext,
                {description = "Next Tagt", group = "tag"}
            ),
            awful.key(
                {modkey}, "Escape", awful.tag.history.restore,
                {description = "Restore Tag", group = "tag"}
            )
        )

        for i = 1, 10 do
            local tag_keys

            if i < 6 then
                tag_keys = create_tag_keys(i)
            else
                tag_keys = create_tag_keys(i - 5, i)
            end

            globalkeys = gears.table.join(globalkeys, tag_keys)
        end

        return globalkeys
    end

    local screen      = args.screen
    local screen_type = display.screen_type(screen)

    awful.tag(
        taglist, screen,
        {
--            awful.layout.suit.floating,
            screen_type == 'ultrawide' and awful.layout.suit.floating or awful.layout.suit.tile,
            screen_type == 'ultrawide' and lain.layout.centerwork or awful.layout.suit.tile,
            screen_type == 'ultrawide' and lain.layout.centerwork or awful.layout.suit.fair,
            awful.layout.suit.floating,
            awful.layout.suit.floating
        }
    )

    return wibox.container.margin(awful.widget.taglist {
        screen = screen,
        filter = awful.widget.taglist.filter.all,
        update_function = listupdate_tags,
        buttons = gears.table.join(
            awful.button({}, 1, function(t) t:view_only() end),
            awful.button({"Control"}, 1, function(t) awful.tag.viewtoggle(t) end)
        ),
    }, 0, dpi(8))
end

return factory
