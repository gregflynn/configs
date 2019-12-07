local naughty = require('naughty')


local debug = {
    preset = {
        position = 'bottom_right',
        timeout = 60
    }
}

function debug.log(title, message)
    naughty.notify({
        preset = debug.preset,
        title = title,
        text = message
    })
end

return debug
