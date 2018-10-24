local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local gears = require("gears")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()

local lain = require("lain")
local sep = lain.util.separators
local home = os.getenv("HOME")
local dotsan_home = "{DS_HOME}"
local lock_script = "{DS_LOCK}"
local assets = home.."/.config/awesome/assets"

local colors = {
    background = "#{DS_BACKGROUND}",
    blue       = "#{DS_BLUE}",
    green      = "#{DS_GREEN}",
    gray       = "#{DS_GRAY}",
    orange     = "#{DS_ORANGE}",
    purple     = "#{DS_PURPLE}",
    red        = "#{DS_RED}",
    white      = "#{DS_WHITE}",
    yellow     = "#{DS_YELLOW}",
    yellow_txt = "#{DS_YELLOW_TEXT}",
}

local theme = {
    home          = home,
    dotsan_home   = dotsan_home,
    lock_script   = lock_script,
    colors        = colors,
    bar_height    = dpi(25),
    bar_margin    = dpi(3),
    border_width  = dpi(3),
    font          = "hack 10",
    wallpaper     = dotsan_home.."/private/wallpapers/close_to_the_sun.jpg",
    border_shape  = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, dpi(5))
    end,
}

sep.width = dpi(9)

theme.bg_normal     = colors.background
theme.bg_focus      = colors.background
theme.bg_urgent     = colors.background
theme.bg_minimize   = colors.background
theme.bg_systray    = colors.background

theme.fg_normal     = colors.white
theme.fg_focus      = colors.blue
theme.fg_urgent     = colors.red
theme.fg_minimize   = colors.purple

theme.useless_gap   = 5
theme.border_normal = colors.background
theme.border_focus  = colors.background
theme.border_marked = colors.red

--
-- Hotkeys
--
theme.hotkeys_font             = "hack 14"
theme.hotkeys_description_font = "hack 12"
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
theme.notification_opacity      = 0.9
theme.notification_font         = "Hack 12"
theme.notification_fg           = colors.white
theme.notification_border_width = dpi(2)
theme.notification_border_color = colors.background
theme.notification_shape        = theme.border_shape

--
-- Taglist
--
theme.taglist_fg_focus = colors.background
theme.taglist_bg_focus = colors.purple

--
-- Tasklist
--
theme.tasklist_fg_focus = colors.background
theme.tasklist_bg_focus = colors.blue
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



theme.layout_fairh = themes_path.."zenburn/layouts/fairh.png"
theme.layout_fairv = themes_path.."zenburn/layouts/fairv.png"
theme.layout_floating  = themes_path.."zenburn/layouts/floating.png"
theme.layout_magnifier = themes_path.."zenburn/layouts/magnifier.png"
theme.layout_max = themes_path.."zenburn/layouts/max.png"
theme.layout_fullscreen = themes_path.."zenburn/layouts/fullscreen.png"
theme.layout_tilebottom = themes_path.."zenburn/layouts/tilebottom.png"
theme.layout_tileleft   = themes_path.."zenburn/layouts/tileleft.png"
theme.layout_tile = themes_path.."zenburn/layouts/tile.png"
theme.layout_tiletop = themes_path.."zenburn/layouts/tiletop.png"
theme.layout_spiral  = themes_path.."zenburn/layouts/spiral.png"
theme.layout_dwindle = themes_path.."zenburn/layouts/dwindle.png"
theme.layout_cornernw = themes_path.."zenburn/layouts/cornernw.png"
theme.layout_cornerne = themes_path.."zenburn/layouts/cornerne.png"
theme.layout_cornersw = themes_path.."zenburn/layouts/cornersw.png"
theme.layout_cornerse = themes_path.."zenburn/layouts/cornerse.png"

theme.lain_icons         = "/usr/share/awesome/lib/lain/icons/layout/zenburn/"
theme.layout_termfair    = theme.lain_icons .. "termfair.png"
theme.layout_centerfair  = theme.lain_icons .. "centerfair.png"  -- termfair.center
theme.layout_cascade     = theme.lain_icons .. "cascade.png"
theme.layout_cascadetile = theme.lain_icons .. "cascadetile.png" -- cascade.tile
theme.layout_centerwork  = theme.lain_icons .. "centerwork.png"
theme.layout_centerhwork = theme.lain_icons .. "centerworkh.png" -- centerwork.horizontal

return theme
