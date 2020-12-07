local gears   = require('gears')
local dstheme = require('dstheme')

local home        = os.getenv('HOME')
local dotsan_home = dstheme.home
local lock_script = dstheme.lock
local assets      = home..'/.config/awesome/sanity/assets'
local font_name   = 'Ubuntu Mono'

local useless_gap = 3
local colors = {
    background = dstheme.background,
    black      = dstheme.black,
    blue       = dstheme.blue,
    green      = dstheme.green,
    gray       = dstheme.gray,
    orange     = dstheme.orange,
    purple     = dstheme.purple,
    red        = dstheme.red,
    white      = dstheme.white,
    yellow     = dstheme.yellow,
}

local theme = {
    home          = home,
    dotsan_home   = dotsan_home,
    lock_script   = lock_script,
    colors        = colors,
    bar_height    = 28 + (useless_gap * 2),
    bar_opacity   = 1.0,
    border_width  = 2,
    widget_space  = 4,
    widget_line   = 3,
    font_name     = font_name,
    font          = font_name..' 11',
    font_notif    = font_name..' 14',
    font_icon     = font_name..' 28',
    wallpaper     = dstheme.wallpaper,
    border_shape  = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, 3)
    end,
}

theme.bg_normal     = colors.background
theme.bg_focus      = colors.background
theme.bg_urgent     = colors.background
theme.bg_minimize   = colors.background
theme.bg_systray    = colors.background

theme.fg_normal     = colors.gray
theme.fg_focus      = colors.white
theme.fg_urgent     = colors.red
theme.fg_minimize   = colors.purple

theme.useless_gap   = useless_gap
theme.border_normal = colors.background
theme.border_focus  = colors.background
theme.border_marked = colors.red
theme.border_ontop  = colors.yellow

theme.normal_opacity = 1.0
theme.focus_opacity  = 1.0

theme.titlebar_fg_normal = colors.gray
theme.titlebar_bg_normal = colors.background

--
-- Hotkeys
--
theme.hotkeys_font             = font_name..' 16'
theme.hotkeys_description_font = font_name..' 12'
theme.hotkeys_fg               = colors.white
theme.hotkeys_modifiers_fg     = colors.blue

--
-- Notifications
--
theme.notification_font         = theme.font_notif
theme.notification_fg           = colors.white
theme.notification_border_width = 5
theme.notification_border_color = colors.background
theme.notification_shape        = theme.border_shape

--
-- Title bar buttons
--
theme.titlebar_close_button_normal = assets..'/button_normal.png'
theme.titlebar_close_button_normal_hover = assets..'/close_hover.png'
theme.titlebar_close_button_normal_press = assets..'/close_press.png'
theme.titlebar_close_button_focus = assets..'/close_focus.png'
theme.titlebar_close_button_focus_hover = assets..'/close_hover.png'
theme.titlebar_close_button_focus_press = assets..'/close_press.png'

theme.titlebar_maximized_button_normal = assets..'/button_normal.png'
theme.titlebar_maximized_button_normal_active = assets..'/button_normal.png'
theme.titlebar_maximized_button_normal_active_hover = assets..'/maximize_hover.png'
theme.titlebar_maximized_button_normal_active_press = assets..'/maximize_press.png'
theme.titlebar_maximized_button_normal_inactive = assets..'/button_normal.png'
theme.titlebar_maximized_button_normal_inactive_hover = assets..'/maximize_hover.png'
theme.titlebar_maximized_button_normal_inactive_press = assets..'/maximize_press.png'
theme.titlebar_maximized_button_focus = assets..'/maximize_focus.png'
theme.titlebar_maximized_button_focus_active = assets..'/maximize_hover.png'
theme.titlebar_maximized_button_focus_active_hover = assets..'/maximize_hover.png'
theme.titlebar_maximized_button_focus_active_press = assets..'/maximize_press.png'
theme.titlebar_maximized_button_focus_inactive = assets..'/maximize_focus.png'
theme.titlebar_maximized_button_focus_inactive_hover = assets..'/maximize_hover.png'
theme.titlebar_maximized_button_focus_inactive_press = assets..'/maximize_press.png'

theme.titlebar_minimize_button_normal = assets..'/button_normal.png'
theme.titlebar_minimize_button_normal_hover = assets..'/minimize_hover.png'
theme.titlebar_minimize_button_normal_press = assets..'/minimize_press.png'
theme.titlebar_minimize_button_focus = assets..'/minimize_focus.png'
theme.titlebar_minimize_button_focus_hover = assets..'/minimize_hover.png'
theme.titlebar_minimize_button_focus_press = assets..'/minimize_press.png'

return theme
