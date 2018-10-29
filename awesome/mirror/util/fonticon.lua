local wibox  = require("wibox")


local fonticon = {
    font = "Hack Nerd Font Mono 20"
}

-- Update the given fonticon widget with the given unicode char
-- @param widget fonticon to update
-- @param unicode string of the format "\u{abcd}"
-- @returns the given widget
function fonticon.update(widget, unicode, color)
    local prefix = string.format(
        "<span font='%s'%s>", fonticon.font,
        color and string.format(" color='%s'", color) or ""
    )
    local suffix = "</span>"
    widget:set_markup(prefix..unicode..suffix)
    return widget
end

-- Create a textbox with the given unicode icon
-- @param unicode string of the format "\u{abcd}"
-- @returns a new fonticon widget
function fonticon.create(unicode, color)
    local widget = wibox.widget.textbox()
    return fonticon.update(widget, unicode or "", color)
end


return fonticon
