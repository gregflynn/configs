local string = string

local beautiful = require('beautiful')

local spawn = require('awful.spawn')

local rofi = {}

local rofi_show_fmt   = 'rofi -show %s -scroll-method 1 -matching normal'
local rofi_script_fmt = string.format('python3 %s/rofi/', beautiful.dotsan_home)

--
-- Program launcher mode for Rofi
--
local rofi_run_cmd = string.format(rofi_show_fmt, 'drun -drun-show-actions')
function rofi:run()
    spawn(rofi_run_cmd)
end

--
-- Password manager frontend
--
local rofi_pass_cmd = 'rofi-pass'
function rofi:pass()
    spawn(rofi_pass_cmd)
end

--
-- Rofi Calculator
--
local rofi_calc_cmd = string.format(rofi_show_fmt, 'calc -modi calc -no-show-match -no-sort')
function rofi:calc()
    spawn(rofi_calc_cmd)
end

--
-- Tag Windows Switcher
--
local rofi_tag_cmd = string.format(rofi_show_fmt, 'windowcd')
function rofi:tagwindows()
    spawn(rofi_tag_cmd)
end

--
-- All Windows Switcher
--
local rofi_clients_cmd = string.format(rofi_show_fmt, 'window')
function rofi:allwindows()
    spawn(rofi_clients_cmd)
end

--
-- Emoji Picker
--
local rofi_emoji_cmd = 'rofimoji'
function rofi:emoji()
    spawn(rofi_emoji_cmd)
end

--
-- Web Search
--
local rofi_web_cmd = rofi_script_fmt..'rofi_search.py'
function rofi:websearch()
    spawn(rofi_web_cmd)
end

--
-- Project Manager
--
local rofi_projects_cmd = rofi_script_fmt..'rofi_project.py'
function rofi:projects()
    spawn(rofi_projects_cmd)
end

local rofi_network_cmd = rofi_script_fmt..'rofi_network.py'
function rofi:network()
    spawn(rofi_network_cmd)
end

local rofi_vpn_cmd = string.format('bash %s/rofi/rofi_vpn.sh', beautiful.dotsan_home)
function rofi:vpn()
    spawn(rofi_vpn_cmd)
end

return rofi
