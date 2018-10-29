local awful     = require("awful")
local beautiful = require("beautiful")
local wibox     = require("wibox")
local gears     = require("gears")

local FontIcon = require("util/fonticon")

local colors = beautiful.colors


local backup_font_icon = "\u{f54a}"
local close_font_icon = "\u{f562}"
local close_font_icon_color = colors.red

local function close_dropdown(dropdown)
    if dropdown.prevmenu then
        dropdown.prevmenu:hide()
        dropdown.prevmenu = nil
    end

    if not dropdown.args.icon then
        dropdown:update(
        dropdown.args.font_icon or backup_font_icon,
        dropdown.args.font_icon_color
        )
    end
end

local function open_dropdown(dropdown)
    if not dropdown.args.icon then
        -- update icon to indicate close action
        dropdown:update(
            close_font_icon,
            dropdown.args.font_icon_color_open or close_font_icon_color
        )
    end

    awful.spawn.easy_async_with_shell(
        dropdown.command,
        function(stdout)
            local menu = awful.menu()

            for item in stdout:gmatch("%S+") do
                local full_path = string.format(
                    "%s/%s", dropdown.args.folder, item
                )
                menu:add({
                    item,
                    function()
                        dropdown.args.menu_func(full_path)
                        close_dropdown(dropdown)
                    end,
                    -- full_path -- icon
                })
            end

            menu:show()
            dropdown.prevmenu = menu
        end
    )
end

local function left_click(dropdown)
    if dropdown.prevmenu then
        close_dropdown(dropdown)
        return
    end

    open_dropdown(dropdown)
end

local function right_click(dropdown)
    if args.right_click then
        awful.spawn(args.right_click)
    else
        awful.spawn(string.format("xdg-open %s", dropdown.args.folder))
    end
end

local function factory(args)
    local args = args or {}
    local Dropdown
    if args.icon then
        Dropdown = wibox.widget {
            image  = args.icon,
            resize = true,
            widget = wibox.widget.imagebox
        }
        Dropdown.args = args
    else
        Dropdown = FontIcon()
        Dropdown.args = args
        close_dropdown(Dropdown)
    end

    if args.tooltip_text then
        awful.tooltip {
            objects = {Dropdown},
            text = args.tooltip_text
        }
    end

    Dropdown.command = string.format(
        "ls -l %s | awk '{print $9}' | tail -n 35 | sort %s",
        args.folder,
        args.reverse and "-r" or ""
    )

    Dropdown:buttons(gears.table.join(
        awful.button({}, 1, function()
            left_click(Dropdown)
        end),
        awful.button({}, 3, function()
            right_click(Dropdown)
        end)
    ))

    return Dropdown
end

return factory
