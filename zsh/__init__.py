from _src.initializer import BaseInitializer


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['zsh', 'oh-my-zsh-git']

    @property
    def install_in_cli(self):
        return True

    def build(self):
        self.inject('zshrc.zsh')

    def install(self):
        self.link_dist('zshrc.zsh', '.zshrc')


def initializer():
    return Initializer