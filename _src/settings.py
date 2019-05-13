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


DOTSAN_SHELL_SOURCES = home_path('.sanity_sources')
DOTSAN_SHELL_SCRIPT = """
for source_script in $(ls -l "{0}" | awk '{{ print $9}}'); do
    source "{0}/$source_script"
done
""".format(DOTSAN_SHELL_SOURCES)
