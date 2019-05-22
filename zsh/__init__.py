from copy import deepcopy

from _src import settings
from _src.initializer import BaseInitializer


ZSH_INJECT_MAP = deepcopy(settings.DEFAULT_INJECT_MAP)


class Initializer(BaseInitializer):
    ANTIGEN = 'antigen/antigen.zsh'

    @property
    def requirements(self):
        return ['zsh']

    @property
    def install_in_cli(self):
        return True

    def build(self):
        ZSH_INJECT_MAP.update({
            'ANTIGEN_INSTALL': self.dist_path(self.ANTIGEN),
            'ZSH_PROMPT': self.base_path('prompt.zsh')
        })
        self.inject('zshrc.zsh', inject_map=ZSH_INJECT_MAP)
        self.checkout('https://github.com/zsh-users/antigen.git', 'antigen')

    def install(self):
        self.link_dist('zshrc.zsh', '.zshrc')


def initializer():
    return Initializer
