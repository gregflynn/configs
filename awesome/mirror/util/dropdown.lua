local awful     = require("awful")
local beautiful = require("beautiful")
local wibox     = require("wibox")
local gears     = require("gears")

local FontIcon = require("util/fonticon")

local colors = beautiful.colors


local backup_font_icon = "\u{f54a}"
local close_font_icon = "\u{f562}"
local close_font_icon_color = colors.white

local function create_dropdown(args)
    local Dropdown
    if args.icon then
        Dropdown = wibox.widget {
            image  = args.icon,
            resize = true,
            widget = wibox.widget.imagebox
        }
    else
        Dropdown = FontIcon()
    end
    return Dropdown
end

local function factory(args)
    local args = args or {}
    local Dropdown = create_dropdown(args)
    local is_font_icon = args.icon == nil

    local command = string.format(
        "ls -l %s | awk '{print $9}' | tail -n 35 | sort %s",
        args.folder,
        args.reverse and "-r" or ""
    )

    if args.tooltip_text then
        Dropdown.tooltip = awful.tooltip {
            objects = {Dropdown},
            text = args.tooltip_text
        }
    end

    function Dropdown:close()
        if Dropdown.prevmenu then
            Dropdown.prevmenu:hide()
            Dropdown.prevmenu = nil
        end

        if is_font_icon then
            Dropdown:update(
                args.font_icon or backup_font_icon,
                args.font_icon_color or colors.background
            )
        end
    end

    function Dropdown:open()
        if is_font_icon then
            -- update icon to indicate close action
            Dropdown:update(
                close_font_icon,
                args.font_icon_color_open or close_font_icon_color
            )
        end

        awful.spawn.easy_async_with_shell(command, function(stdout)
            local menu = awful.menu()

            for item in stdout:gmatch("%S+") do
                local full_path = string.format("%s/%s", args.folder, item)
                menu:add({
                    item,
                    function()
                        args.menu_func(full_path)
                        Dropdown:close()
                    end,
                    -- full_path -- icon
                })
            end

            menu:show()
            Dropdown.prevmenu = menu
        end)
    end

    Dropdown:buttons(gears.table.join(
        awful.button({}, 1, function()
            if Dropdown.prevmenu then
                Dropdown:close()
            else
                Dropdown:open()
            end
        end),
        awful.button({}, 3, function()
            if args.right_click then
                awful.spawn(args.right_click)
            else
                awful.spawn(string.format("xdg-open %s", args.folder))
            end
        end)
    ))

    Dropdown:close()

    return Dropdown
end

return factory
