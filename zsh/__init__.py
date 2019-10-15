from _src.initializer import BaseInitializer


class Initializer(BaseInitializer):
    ANTIGEN = 'antigen/antigen.zsh'

    @property
    def requirements(self):
        return ['zsh', 'fzf']

    def build(self):
        inject_map = {
            'ANTIGEN_INSTALL': self.dist_path(self.ANTIGEN),
            'ZSH_PROMPT': self.base_path('prompt.zsh')
        }
        self.inject('zshrc.zsh', inject_map=inject_map)
        self.checkout('https://github.com/zsh-users/antigen.git', 'antigen')

    def install(self):
        self.link_dist('zshrc.zsh', '.zshrc')
