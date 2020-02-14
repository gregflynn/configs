local beautiful = require("beautiful")
local theme_assets = beautiful.theme_assets
local dpi = beautiful.xresources.apply_dpi

local gears = require("gears")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()

local home = os.getenv("HOME")
local dotsan_home = "{DS_HOME}"
local lock_script = "{DS_LOCK}"
local assets = home.."/.config/awesome/assets"
local font_name = "Hack Nerd Font Mono"

local colors = {
    background = "#{DS_BACKGROUND}",
    black      = "#{DS_BLACK}",
    blue       = "#{DS_BLUE}",
    green      = "#{DS_GREEN}",
    gray       = "#{DS_GRAY}",
    orange     = "#{DS_ORANGE}",
    purple     = "#{DS_PURPLE}",
    red        = "#{DS_RED}",
    white      = "#{DS_WHITE}",
    yellow     = "#{DS_YELLOW}",
}

local theme = {
    home          = home,
    dotsan_home   = dotsan_home,
    lock_script   = lock_script,
    colors        = colors,
    bar_height    = dpi(28),
    bar_opacity   = 1.0,
    border_width  = dpi(3),
    widget_space  = dpi(5),
    widget_under  = dpi(3),
    font          = font_name.." 10",
    font_notif    = font_name.." 14",
    font_icon     = font_name.." 20",
    wallpaper     = "{DS_WALLPAPER}",
    border_shape  = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, dpi(0))
    end,
}

theme.bg_normal     = colors.background
theme.bg_focus      = colors.background
theme.bg_urgent     = colors.background
theme.bg_minimize   = colors.background
theme.bg_systray    = colors.orange

theme.fg_normal     = colors.white
theme.fg_focus      = colors.yellow
theme.fg_urgent     = colors.red
theme.fg_minimize   = colors.purple

theme.useless_gap   = 3
theme.border_normal = colors.background
theme.border_focus  = colors.yellow
theme.border_marked = colors.red

--
-- Hotkeys
--
theme.hotkeys_font             = font_name.." 16"
theme.hotkeys_description_font = font_name.." 12"
theme.hotkeys_fg               = colors.white
theme.hotkeys_modifiers_fg     = colors.blue

--
-- Menus
--
theme.menu_submenu_icon = themes_path.."default/submenu.png"
theme.menu_height       = dpi(20)
theme.menu_width        = dpi(300)

--
-- Notifications
--
theme.notification_font         = theme.font_notif
theme.notification_fg           = colors.white
theme.notification_border_width = dpi(4)
theme.notification_border_color = colors.background
theme.notification_shape        = theme.border_shape

--
-- Taglist
--
theme.taglist_fg_focus = colors.white
theme.taglist_bg_focus = colors.purple

--
-- Tasklist
--
theme.tasklist_fg_focus = colors.yellow
theme.tasklist_fg_minimize = colors.purple
theme.tasklist_plain_task_name = true

--
-- Titlebar buttons
--
theme.titlebar_close_button_normal = assets.."/button_normal.png"
theme.titlebar_close_button_normal_hover = assets.."/close_hover.png"
theme.titlebar_close_button_normal_press = assets.."/close_press.png"
theme.titlebar_close_button_focus = assets.."/close_focus.png"
theme.titlebar_close_button_focus_hover = assets.."/close_hover.png"
theme.titlebar_close_button_focus_press = assets.."/close_press.png"

theme.titlebar_maximized_button_normal = assets.."/button_normal.png"
theme.titlebar_maximized_button_normal_active = assets.."/button_normal.png"
theme.titlebar_maximized_button_normal_active_hover = assets.."/maximize_hover.png"
theme.titlebar_maximized_button_normal_active_press = assets.."/maximize_press.png"
theme.titlebar_maximized_button_normal_inactive = assets.."/button_normal.png"
theme.titlebar_maximized_button_normal_inactive_hover = assets.."/maximize_hover.png"
theme.titlebar_maximized_button_normal_inactive_press = assets.."/maximize_press.png"
theme.titlebar_maximized_button_focus = assets.."/maximize_focus.png"
theme.titlebar_maximized_button_focus_active = assets.."/maximize_hover.png"
theme.titlebar_maximized_button_focus_active_hover = assets.."/maximize_hover.png"
theme.titlebar_maximized_button_focus_active_press = assets.."/maximize_press.png"
theme.titlebar_maximized_button_focus_inactive = assets.."/maximize_focus.png"
theme.titlebar_maximized_button_focus_inactive_hover = assets.."/maximize_hover.png"
theme.titlebar_maximized_button_focus_inactive_press = assets.."/maximize_press.png"

theme.titlebar_minimize_button_normal = assets.."/button_normal.png"
theme.titlebar_minimize_button_normal_hover = assets.."/minimize_hover.png"
theme.titlebar_minimize_button_normal_press = assets.."/minimize_press.png"
theme.titlebar_minimize_button_focus = assets.."/minimize_focus.png"
theme.titlebar_minimize_button_focus_hover = assets.."/minimize_hover.png"
theme.titlebar_minimize_button_focus_press = assets.."/minimize_press.png"

theme.awesome_icon = theme_assets.awesome_icon(
    theme.menu_height, theme.bg_focus, theme.fg_focus
)

theme.layout_floating  = themes_path.."zenburn/layouts/floating.png"

return theme
