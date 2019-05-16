import os


HOME = os.getenv('HOME')
MODULE_DIST_DIR = 'dist'
DOTSAN_DIR = '.sanity'


def home_path(*extra):
    return os.path.join(HOME, *extra)


def ds_path(*extra):
    return home_path(DOTSAN_DIR, *extra)


def module_path(module_name, *extra):
    return ds_path(module_name, *extra)


def dist_path(module_name, *extra):
    return module_path(module_name, MODULE_DIST_DIR, *extra)


DOTSAN_HOME = ds_path()
DOTSAN_LOCK = dist_path('x11', 'i3lock.sh')
DOTSAN_WALLPAPER = module_path('private', 'wallpapers', 'light_lanes.png')


class Colors:
    BACKGROUND = '2D2A2E'

    BLACK = '080808'
    GRAY = '939293'
    WHITE = 'FCFCFA'

    BLUE = '78DCE8'
    CYAN = 'A1EFE4'
    GREEN = 'A9DC76'
    ORANGE = 'FC9867'
    PURPLE = 'AB9DF2'
    RED = 'FF6188'
    YELLOW = 'FFD866'


DOTSAN_SHELL_BIN = ds_path('_bin')
DOTSAN_SHELL_COMP = ds_path('_comp')
DOTSAN_SHELL_SOURCES = ds_path('_shell')
DOTSAN_SHELL_COMP_BASH = DOTSAN_SHELL_COMP + '/bash'
DOTSAN_SHELL_COMP_ZSH = DOTSAN_SHELL_COMP + '/zsh'

DOTSAN_SOURCE_SCRIPT = """
__ds__src() {
    for source_script in $(ls -l "$1" | awk '{ print $9}'); do
        . "$1/$source_script"
    done
}
"""

DEFAULT_INJECT_MAP = {
    'DS_HOME': DOTSAN_HOME,
    'DS_LOCK': DOTSAN_LOCK,
    'DS_WALLPAPER': DOTSAN_WALLPAPER,
    'DS_SOURCE': DOTSAN_SOURCE_SCRIPT,
    'DS_BIN': DOTSAN_SHELL_BIN,
    'DS_SOURCES': DOTSAN_SHELL_SOURCES,

    'DS_COMP_BASH': DOTSAN_SHELL_COMP_BASH,
    'DS_COMP_ZSH': DOTSAN_SHELL_COMP_ZSH,

    'DS_BACKGROUND': Colors.BACKGROUND,
    'DS_BLACK': Colors.BLACK,
    'DS_GRAY': Colors.GRAY,
    'DS_WHITE': Colors.WHITE,

    'DS_BLUE': Colors.BLUE,
    'DS_CYAN': Colors.CYAN,
    'DS_GREEN': Colors.GREEN,
    'DS_ORANGE': Colors.ORANGE,
    'DS_PURPLE': Colors.PURPLE,
    'DS_RED': Colors.RED,
    'DS_YELLOW': Colors.YELLOW
}

BASH_WRAPPER = """
#!/usr/bin/env bash
{ds_src_script}
__ds__src {ds_src}
""".format(ds_src_script=DOTSAN_SOURCE_SCRIPT, ds_src=DOTSAN_SHELL_SOURCES)
BIN_WRAPPERS = {
    'default': BASH_WRAPPER,
    'bash': BASH_WRAPPER
}
