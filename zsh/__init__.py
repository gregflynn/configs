from _src.initializer import BaseInitializer


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['zsh', 'oh-my-zsh-git']

    @property
    def install_in_cli(self):
        return True

    def install(self):
        self.link_base('zshrc', '.zshrc')


def initializer():
    return Initializer
