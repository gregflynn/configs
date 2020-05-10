import os
import stat
from enum import Enum, auto


HOME = os.getenv('HOME')
DOTSAN_CONFIG_HOME = os.getenv('DOTSAN_CONFIG_HOME')
MODULE_DIST_DIR = 'dist'
DOTSAN_DIR = '.sanity'


def home_path(*extra):
    return os.path.join(HOME, *extra)


def ds_path(*extra):
    return home_path(DOTSAN_DIR, *extra)


def ds_config_path(*extra):
    return os.path.join(DOTSAN_CONFIG_HOME, *extra)


def module_path(module_name, *extra):
    return ds_path('modules', module_name, *extra)


def dist_path(module_name, *extra):
    return ds_config_path('dists', module_name, *extra)


def assert_dir(path):
    dir_path = os.path.dirname(path)
    if not os.path.exists(dir_path):
        os.makedirs(dir_path, exist_ok=True)


DOTSAN_HOME = ds_path()
MODULE_HOME_DIR = ds_path('modules')
DOTSAN_LOCK = dist_path('x11', 'i3lock.sh')
DOTSAN_WALLPAPER = module_path('private', 'wallpapers', '10-12.jpg')


class Colors:
    BACKGROUND = '2D2A2E'

    BLACK = '080808'
    GRAY = '939293'
    WHITE = 'FCFCFA'

    BLUE = '78DCE8'
    GREEN = 'A9DC76'
    ORANGE = 'FC9867'
    PURPLE = 'AB9DF2'
    RED = 'FF6188'
    YELLOW = 'FFD866'


DOTSAN_SHELL_BIN = ds_config_path('bin')
DOTSAN_SHELL_COMP = ds_config_path('comp')
DOTSAN_SHELL_SOURCES = ds_config_path('shell')
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
    'HOME': HOME,
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
    'DS_GREEN': Colors.GREEN,
    'DS_ORANGE': Colors.ORANGE,
    'DS_PURPLE': Colors.PURPLE,
    'DS_RED': Colors.RED,
    'DS_YELLOW': Colors.YELLOW
}


class ExecWrapper(Enum):
    BASH = auto()
    PYTHON = auto()

    @staticmethod
    def render(bin_type: 'ExecWrapper', executable: str, name: str):
        """Render an exec wrapper to a file

        Args:
            bin_type:
            executable:
            name:
        """
        bin_path = os.path.join(DOTSAN_SHELL_BIN, name)
        assert_dir(bin_path)
        with open(bin_path, 'w') as ex:
            wrapper = BIN_WRAPPERS[bin_type]
            ex.write(wrapper.replace(BIN_WRAPPER_PLACEHOLDER, executable))
        os.chmod(bin_path, stat.S_IRWXU)


BIN_WRAPPER_PLACEHOLDER = 'DS_EXEC_DS'
BIN_WRAPPERS = {
    ExecWrapper.BASH: f"""#!/usr/bin/env bash
        {DOTSAN_SOURCE_SCRIPT}
        __ds__src {DOTSAN_SHELL_SOURCES}
        {BIN_WRAPPER_PLACEHOLDER}
        """,
    ExecWrapper.PYTHON: f"""#!/usr/bin/env bash
        export DOTSAN_CONFIG_HOME={DOTSAN_CONFIG_HOME}
        . "{DOTSAN_CONFIG_HOME}/venv/bin/activate"
        python3 {BIN_WRAPPER_PLACEHOLDER} $@
        deactivate
        """
}
