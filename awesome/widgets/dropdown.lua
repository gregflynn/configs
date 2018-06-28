local awful     = require("awful")
local beautiful = require("beautiful")
local wibox     = require("wibox")
local gears     = require("gears")
local naughty   = require("naughty")
local dpi       = beautiful.xresources.apply_dpi

local function factory(args)
    local new_dropdown = wibox.widget {
        image  = args.icon,
        resize = true,
        prevmenu   = nil,
        menu_shown = false,
        widget = wibox.widget.imagebox
    }

    local rev = ''
    if args.reverse then
        rev = '-r'
    end

    local command = string.format(
        "ls -l %s | awk '{print $9}' | tail -n 35 | sort %s",
        args.folder,
        rev
    )

    new_dropdown:buttons(gears.table.join(
        awful.button({}, 1, function()
            if new_dropdown.prevmenu then
                new_dropdown.prevmenu:hide()
                new_dropdown.prevmenu = nil
                return
            end

            awful.spawn.easy_async_with_shell(
                command,
                function(stdout, stderr, reason, exit_code)
                    local menu = awful.menu()
    
                    for item in stdout:gmatch("%S+") do
                        local full_path = string.format(
                            "%s/%s", args.folder, item
                        )
                        menu:add({
                            item,
                            function()
                                args.menu_func(full_path)
                                new_dropdown.prevmenu = nil
                            end,
                            -- full_path -- icon
                        })
                    end
    
                    menu:show()
                    new_dropdown.prevmenu = menu
                end
            )
        end),
        awful.button({}, 3, function()
            if args.right_click then
                awful.spawn(args.right_click)
            else
                awful.spawn(string.format("xdg-open %s", args.folder))
            end
        end)
    ))

    return new_dropdown
end

return factory
