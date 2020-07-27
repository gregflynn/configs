local next, tag_colors = next, tag_colors

local awful      = require('awful')
local beautiful  = require('beautiful')
local gears      = require('gears')
local FontIcon   = require('sanity/util/fonticon')
local Container  = require('sanity/util/container')
local DoubleWide = require('sanity/util/doublewide')

local fixed  = require('wibox.layout.fixed')

local colors = beautiful.colors

local boxes = setmetatable({}, {__mode = 'kv'})

local function create_screen_widgets(screen)
    if not screen then
        return
    end

    boxes[screen] = {}

    for tag_idx=1, #screen.tags do
        local tag_font_icon      = FontIcon {small = true, size = 16, margin_l = 4}
        local tag_name_font_icon = FontIcon {small = true}
        local icon_container     = Container {
            widget = DoubleWide {
                left_widget = tag_name_font_icon,
                right_widget = tag_font_icon,
            },
            buttons = gears.table.join(
                awful.button({}, 1, function() screen.tags[tag_idx]:view_only() end),
                awful.button({}, 3, function() screen.tags[tag_idx]:view_only() end),
                awful.button({}, 5, function() awful.tag.viewnext() end),
                awful.button({}, 4, function() awful.tag.viewprev() end)
            ),
            no_tooltip = true
        }
        boxes[screen][tag_idx] = {
            tfi  = tag_font_icon,
            tnfi = tag_name_font_icon,
            c    = icon_container
        }
    end
end

local function update(screen, container)
    local focused_screen = awful.screen.focused()
    local selected_tag_name = focused_screen.selected_tag and focused_screen.selected_tag.name or ''

    local cache = boxes[screen]
    if not cache then
        create_screen_widgets(screen)
        cache = boxes[screen]
    end

    for tag_idx=1, #screen.tags do
        local tag = screen.tags[tag_idx]
        local tag_name = tag.name
        local num_tag_clients = #tag:clients()
        local tag_cache = cache[tag_idx]

        local tag_font_icon    = tag_cache.tfi
        local tag_name_font_icon = tag_cache.tnfi
        local icon_container   = tag_cache.c

        local fg_color = colors.gray
        local bg_color = colors.background

        if tag_name == selected_tag_name then
            fg_color = tag_colors[tag_idx]
            bg_color = fg_color
        end

        tag_font_icon:update(num_tag_clients, fg_color)
        tag_name_font_icon:update(tag_name, fg_color)
        icon_container:set_color(bg_color)

        if container then
            container:add(icon_container)
        end
    end
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
