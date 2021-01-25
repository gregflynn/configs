local string = string

local beautiful = require('beautiful')

local spawn = require('awful.spawn')

local rofi = {}

local rofi_show_fmt   = 'rofi -show %s -scroll-method 1 -matching normal'
local rofi_script_fmt = string.format('python3 %s/modules/rofi/', beautiful.dotsan_home)
local rofi_actions_fmt = rofi_script_fmt..'rofi_actions.py '

function rofi:run()
    spawn(string.format(rofi_show_fmt, 'drun -drun-show-actions'))
end

function rofi:pass()
    spawn('rofi-pass')
end

function rofi:calc()
    spawn(rofi_actions_fmt..'calc')
end

function rofi:tagwindows()
    spawn(string.format(rofi_show_fmt, 'windowcd'))
end

function rofi:allwindows()
    spawn(string.format(rofi_show_fmt, 'window'))
end

function rofi:emoji()
    spawn(rofi_actions_fmt..'emoji')
end

function rofi:websearch()
    spawn(rofi_actions_fmt..'search')
end

function rofi:projects()
    spawn(rofi_actions_fmt..'project')
end

function rofi:actions()
    spawn(rofi_actions_fmt..'actions')
end

return rofi
