local next, string, tag_colors, tonumber = next, string, tag_colors, tonumber

local awful     = require('awful')
local gears     = require('gears')
local FontIcon  = require('sanity/util/fonticon')
local Container = require('sanity/util/container')

local fixed  = require('wibox.layout.fixed')
local widget = require('wibox.widget')

local layout_font_icons = {
    ['machi']    = '﩯',
    ['floating'] = '',
}

local boxes = setmetatable({}, {__mode = 'kv'})

local function next_tag()
    awful.tag.viewnext()
end

local function prev_tag()
    awful.tag.viewprev()
end

local function create_screen_widgets(screen)
    local tag_font_icon    = FontIcon {small = true, size = 16, margin_l = 4}
    local layout_font_icon = FontIcon {small = true}
    local icon_container   = Container {
        widget = widget {
            layout = fixed.horizontal,
            tag_font_icon,
            layout_font_icon
        },
        top     = true,
        buttons = gears.table.join(
            awful.button({}, 1, next_tag),
            awful.button({}, 3, prev_tag),
            awful.button({}, 4, next_tag),
            awful.button({}, 5, prev_tag),
            awful.button({}, 6, prev_tag),
            awful.button({}, 7, next_tag)
        ),
    }
    boxes[screen] = {
        tfi = tag_font_icon,
        lfi = layout_font_icon,
        c   = icon_container
    }
end

local function update(screen)
    local cache = boxes[screen]
    if not cache then
        create_screen_widgets(screen)
        cache = boxes[screen]
    end

    local tag_font_icon    = cache.tfi
    local layout_font_icon = cache.lfi
    local icon_container   = cache.c

    local tn       = awful.screen.focused().selected_tag.name
    local fg_color = tag_colors[tonumber(tn)]
    local layout   = awful.layout.getname(awful.layout.get(screen))

    tag_font_icon:update(tn, fg_color)
    layout_font_icon:update(layout_font_icons[layout], fg_color)
    icon_container:set_color(fg_color)
    icon_container:set_tooltip_color(string.format('%s: %s', tn, layout), nil, fg_color)

    return icon_container
end

local function update_from_tag()
    if boxes[screen] then
        update(screen)
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
            tag_container:add(update(s))
        end,
        layout = fixed.vertical
    }
end

return factory
