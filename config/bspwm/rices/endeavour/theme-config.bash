#############################
#	   Endeavour Theme		#
#############################
# Copyright (C) 2021-2026 gh0stzk <z0mbi3.zk@protonmail.com>
# https://github.com/gh0stzk/dotfiles
# Rice "endeavour" — paleta púrpura/magenta de EndeavourOS (lucioamarilla)

# (EndeavourOS) colorscheme
bg="#161120"
bg_alt="#00161120"
fg="#e3d8f5"
trans="#00161120"

black="#0f0b17"
red="#ef5a75"
green="#84e29b"
yellow="#f2c980"
blue="#9d82f8"
magenta="#dc35ee"
cyan="#79dff0"
white="#c8bce8"
blackb="#52486e"
redb="#f97ea2"
greenb="#9becb0"
yellowb="#f6d79c"
blueb="#b3a3fa"
magentab="#ea75f6"
cyanb="#8fe7f6"
whiteb="#e3d8f5"

# Extend
purple="#7f3fbf"		# EndeavourOS brand purple
amber="#ffbf5f"
pink="#f4a1e6"
orange="#ff966c"
indigo="#6C77BB"
lime="#b8d96b"
grey="#9d92bd"
bluegray="#7c6fa0"

accent_color="#241a38"
arch_icon="#7f3fbf"		# glyph Arch  coloreado púrpura EOS

# Bar
main_bar="bar07"

# Bspwm options
BORDER_WIDTH="0"		# Bspwm border
TOP_PADDING="1"
BOTTOM_PADDING="1"
LEFT_PADDING="1"
RIGHT_PADDING="1"
NORMAL_BC="$purple"     # Normal border color
FOCUSED_BC="$magenta"   # Focused border color

# Terminal font & size
term_font_size="10"
term_font_name="JetBrainsMono Nerd Font"

# Picom options
P_FADE="true"			# Fade true|false
P_SHADOWS="true"		# Shadows true|false
SHADOW_C="#000000"		# Shadow color
P_CORNER_R="6"			# Corner radius (0 = disabled)
P_BLUR="false"			# Blur true|false
P_ANIMATIONS="@"		# (@ = enable) (# = disable)
P_TERM_OPACITY="1.0"	# Terminal transparency. Range: 0.1 - 1.0 (1.0 = disabled)

# Dunst
dunst_offset='(20, 60)'
dunst_origin='top-right'
dunst_transparency='0'
dunst_corner_radius='6'
dunst_font='JetBrainsMono NF Medium 9'
dunst_border='0'
dunst_frame_color="$accent_color"
dunst_icon_theme="Zafiro-Purple"
# Dunst animations
dunst_close_preset="fly-out"
dunst_close_direction="up"
dunst_open_preset="fly-in"
dunst_open_direction="up"

# Jgmenu colors
jg_bg="$bg"
jg_fg="$fg"
jg_sel_bg="$accent_color"
jg_sel_fg="$fg"
jg_sep="$blackb"

# Rofi menu font and colors
rofi_font="JetBrainsMono NF Bold 9"
rofi_background="$bg"
rofi_bg_alt="$accent_color"
rofi_background_alt="${bg}E0"
rofi_fg="$fg"
rofi_selected="$magentab"
rofi_active="$green"
rofi_urgent="$red"

# Screenlocker
sl_bg="${bg}"
sl_fg="${fg}"
sl_ring="${black}"
sl_wrong="${red}"
sl_date="${fg}"
sl_verify="${green}"

# Gtk theme
gtk_theme="LoveLace-zk"
gtk_icons="Zafiro-Purple"
gtk_cursor="Qogirr-Dark"
geany_theme="z0mbi3-LoveLace"

# Wallpaper engine
# Available engines:
# - Random  (Set a random wallpaper from Walls rice directory)
# - CustomDir   (Set a random wallpaper from the directory you specified)
# - Default (Sets a specific image as wallpaper) *Default
# - Animated (Set an animated wallpaper. "mp4, mkv, gif")
# - Slideshow (Change randomly every 15 minutes your wallpaper from Walls rice directory)
ENGINE="Default"

CUSTOM_DIR="/path/to/your/wallpapers/directory"
DEFAULT_WALL="$HOME/.config/bspwm/rices/endeavour/walls/wall-01.webp"
ANIMATED_WALL="$HOME/.config/bspwm/config/assets/animated_wall.mp4"
