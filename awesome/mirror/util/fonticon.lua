local wibox  = require("wibox")


local fonticon_font = "Hack Nerd Font Mono 20"

function factory(args)
    local FontIcon = wibox.widget.textbox()

    function FontIcon:update(icon, color)
        local prefix = string.format(
            "<span font='%s'%s>", fonticon_font,
            color and string.format(" color='%s'", color) or ""
        )
        local suffix = "</span>"
        FontIcon:set_markup(prefix..icon..suffix)
    end

    FontIcon:update(args.icon or "", args.color)

    return FontIcon
end


return factory
