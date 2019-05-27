from _src import settings
from _src.initializer import BaseInitializer


PACMAN_CACHE = '/var/cache/pacman/pkg/'
PACMAN_LOG = '/var/log/pacman.log'
AUR_HOME = settings.home_path('.aur')
IS_AUR_PKG = """
__pac__is__aur__pkg() {{
    if [[ -e "{}/$1" ]]; then return 0;
    else return 1;
    fi
}}
""".format(AUR_HOME)
PACKAGE_WATCH_LIST = {
    'alacritty', 'awesome', 'linux', 'nvidia', 'python', 'systemd'
}
INJECT_MAP = {
    'PACMAN_CACHE': PACMAN_CACHE,
    'PACMAN_LOG': PACMAN_LOG,
    'AUR_HOME': AUR_HOME,
    'IS_AUR_PKG': IS_AUR_PKG,
    'PACKAGE_WATCH_LIST': ' '.join(PACKAGE_WATCH_LIST)
}


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['pacman']

    @property
    def install_in_cli(self):
        return True

    def build(self):
        self.inject('pacman.sh', inject_map=INJECT_MAP)
        self.inject('aur.sh', inject_map=INJECT_MAP)
        self.inject('aur-completions.bash', inject_map=INJECT_MAP)
        self.inject('aur-completions.zsh', inject_map=INJECT_MAP)

    def install(self):
        self.bin(
            'pac',
            '. {}\n__pac $@'.format(self.dist_path('pacman.sh')),
            bash_comp=self.base_path('pacman-completions.bash'),
            zsh_comp=self.base_path('pacman-completions.zsh')
        )
        self.bin(
            'aur',
            '. {}\n__aur $@'.format(self.dist_path('aur.sh')),
            bash_comp=self.dist_path('aur-completions.bash'),
            zsh_comp=self.dist_path('aur-completions.zsh')
        )


def initializer():
    return Initializer
