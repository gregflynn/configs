local widget = require('wibox.widget')
local fixed  = require('wibox.layout.fixed')

function factory(args)
    local left_widget = args.left_widget
    local right_widget = args.right_widget

    return widget {
        layout = fixed.horizontal,
        left_widget, right_widget
    }
end

return factory
