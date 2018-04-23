local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local gears = require("gears")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()

local lain = require("lain")
local sep = lain.util.separators

local colors = {
    background = "#272822",
    blue       = "#66D9EF",
    green      = "#A6E22E",
    grey       = "#75715e",
    orange     = "#FD971F",
    purple     = "#ab9df2",
    red        = "#F92672",
    white      = "#F8F8F2",
    yellow     = "#f4bf75"
}

local theme = {
    colors       = colors,
    bar_height   = dpi(25),
    bar_margin   = dpi(3),
    border_width = dpi(2),
    rounded_rect_shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, dpi(10))
    end
}

sep.width = dpi(9)

theme.font          = "hack 10"

theme.bg_normal     = colors.background
theme.bg_focus      = colors.background
theme.bg_urgent     = colors.background
theme.bg_minimize   = colors.background
theme.bg_systray    = colors.background

theme.fg_normal     = colors.white
theme.fg_focus      = colors.blue
theme.fg_urgent     = colors.red
theme.fg_minimize   = colors.purple

theme.useless_gap   = 10
theme.border_normal = colors.background
theme.border_focus  = colors.blue
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
theme.notification_shape        = theme.rounded_rect_shape

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

theme.titlebar_close_button_normal = themes_path.."zenburn/titlebar/close_normal.png"
theme.titlebar_close_button_focus  = themes_path.."zenburn/titlebar/close_focus.png"

theme.titlebar_minimize_button_normal = themes_path.."zenburn/titlebar/ontop_normal_inactive.png"
theme.titlebar_minimize_button_focus  = themes_path.."zenburn/titlebar/ontop_focus_inactive.png"

theme.titlebar_ontop_button_normal_inactive = themes_path.."zenburn/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = themes_path.."zenburn/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = themes_path.."zenburn/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active  = themes_path.."zenburn/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = themes_path.."zenburn/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = themes_path.."zenburn/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = themes_path.."zenburn/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active  = themes_path.."zenburn/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = themes_path.."zenburn/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive  = themes_path.."zenburn/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = themes_path.."zenburn/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active  = themes_path.."zenburn/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = themes_path.."zenburn/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = themes_path.."zenburn/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = themes_path.."zenburn/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active  = themes_path.."zenburn/titlebar/maximized_focus_active.png"

theme.wallpaper = "/home/greg/Dropbox/Wallpapers/sky_mirror_UltraHD.jpg"

-- You can use your own layout icons like this:
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

-- Generate Awesome icon:
theme.awesome_icon = beautiful.theme_assets.awesome_icon(
    theme.menu_height, theme.bg_focus, theme.fg_focus
)

return theme
