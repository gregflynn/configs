local next, tag_colors = next, tag_colors

local awful      = require('awful')
local beautiful  = require('beautiful')
local wibox      = require('wibox')
local gears      = require('gears')
local display    = require('sanity/util/display')
local FontIcon   = require('sanity/util/fonticon')
local Container  = require('sanity/util/container')
local timer      = require('sanity/util/timer')

local fixed  = require('wibox.layout.fixed')

local colors = beautiful.colors

local boxes = setmetatable({}, {__mode = 'kv'})
local floating_tags = {'', '', '', '', ''}

local tag_icons = {}
for idx=1, #tags do
    tag_icons[idx] = FontIcon {
        icon = tags[idx], size = 100, color = colors.background
    }
end

local margin_size = 20
local tag_margins = {}
for idx=1, #tags do
    tag_margins[idx] = wibox.container.margin(
        tag_icons[idx],
        margin_size,
        margin_size
    )
end

local initial_load = true
local last_tag_index
local last_timer

local tag_popup = awful.popup {
    widget = {
        {
            tag_margins[1],
            tag_margins[2],
            tag_margins[3],
            tag_margins[4],
            tag_margins[5],
            layout = wibox.layout.fixed.horizontal,
        },
        margins = 10,
        widget  = wibox.container.margin
    },
    placement    = awful.placement.centered,
    shape        = gears.shape.rounded_rect,
    visible      = false,
    ontop        = true,
    opacity      = 0.9
}

local function show_popup(tag_idx)
    for idx=1, #tags do
        local c = colors.gray
        if idx == tag_idx then
            c = tag_colors[idx]
        end
        tag_icons[idx]:update(tags[idx], c)
    end

    tag_popup.visible = true
    if last_timer then
        last_timer:stop()
    end
    last_timer = timer.delay(function() tag_popup.visible = false end, 0.5)
end

local function create_screen_widgets(screen)
    if not screen then
        return
    end

    local tag_name_font_icon = FontIcon {large = true}
    local icon_container     = Container {
        widget = display.center(tag_name_font_icon),
        buttons = gears.table.join(
            awful.button({}, 1, function() awful.tag.viewnext(screen) end),
            awful.button({}, 3, function() awful.tag.viewprev(screen) end)
        ),
        no_tooltip = true
    }
    boxes[screen] = {
        tnfi = tag_name_font_icon,
        c    = icon_container
    }
end

local function update(screen, container)
    local focused_screen = awful.screen.focused()
    local selected_tag_name = focused_screen.selected_tag and focused_screen.selected_tag.name or ''

    local cache = boxes[screen]
    if not cache then
        create_screen_widgets(screen)
        cache = boxes[screen]
    end

    local tag_idx = focused_screen.selected_tag and focused_screen.selected_tag.index or 1
    local tag = screen.tags[tag_idx]
    local tag_name = tag.name

    local tag_name_font_icon = cache.tnfi
    local icon_container   = cache.c

    local fg_color = colors.gray
    local bg_color = colors.background

    if tag_name == selected_tag_name then
        fg_color = tag_colors[tag_idx]
        bg_color = fg_color
    end

    if tag.layout.name == 'floating' then
        tag_name = floating_tags[tag_idx]
    end

    tag_name_font_icon:update(tag_name, fg_color)
    icon_container:set_color(bg_color)

    if container then
        container:add(icon_container)
    end

    -- only show after tag index changes because this gets called when selected client changes
    if not initial_load and tag_idx ~= last_tag_index then
        show_popup(tag_idx)
    end
    last_tag_index = tag_idx
    initial_load = false
end

local function get_screen(s)
    return s and screen[s]
end

local function update_from_tag(t)
    local s = get_screen(t.screen)
    if boxes[s] then
        update(s)
    end
end

tag.connect_signal('property::selected', update_from_tag)
tag.connect_signal('property::layout', update_from_tag)
tag.connect_signal('property::screen', function()
    for s, _ in next, boxes do
        if s.valid then
            update(s)
        end
    end
end)

local function factory(args)
    local s = args.screen

    return awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
        update_function = function(tag_container)
            tag_container:reset()
            update(s, tag_container)
        end,
        layout = fixed.vertical
    }
end

return factory
