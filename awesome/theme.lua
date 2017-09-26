local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()

local theme = {}

theme.font          = "hack 10"

theme.bg_normal     = "#1B1D1E"
theme.bg_focus      = "#1B1D1E"
theme.bg_urgent     = "#1B1D1E"
theme.bg_minimize   = "#1B1D1E"
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = "#75715E"
theme.fg_focus      = "#A6E22E"
theme.fg_urgent     = "#F92672"
theme.fg_minimize   = "#66D9EF"

theme.useless_gap   = 10
theme.border_width  = 0
theme.border_normal = "#000000"
theme.border_focus  = "#535d6c"
theme.border_marked = "#91231c"

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
theme.titlebar_fg_focus = theme.fg_minimize
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- prompt_[fg|bg|fg_cursor|bg_cursor|font]
-- hotkeys_[bg|fg|border_width|border_color|shape|opacity|modifiers_fg|label_bg|label_fg|group_margin|font|description_font]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- Variables set for theming notifications:
-- notification_font
-- notification_[bg|fg]
-- notification_[width|height|margin]
-- notification_[border_color|border_width|shape|opacity]

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = themes_path.."default/submenu.png"
theme.menu_height = dpi(50)
theme.menu_width  = dpi(500)

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua

-- Define the image to load
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

theme.wallpaper = "/home/greg/Dropbox/Wallpapers/heaven.jpg"

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
