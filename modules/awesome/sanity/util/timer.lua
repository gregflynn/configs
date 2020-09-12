local gears = require('gears')

local timer = {}

function timer.delay(f, amount)
    return gears.timer.weak_start_new(amount or 0.2, function()
        f()
        return false
    end)
end

function timer.loop(refresh, f)
    local function update()
        f()
        return true
    end
    local t = gears.timer.start_new(refresh, update)
    t:emit_signal('timeout')
    return t
end

return timer
