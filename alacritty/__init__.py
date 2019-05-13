from _src.initializer import BaseInitializer


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['alacritty', 'tmux']

    def build(self):
        self.inject('alacritty.yml')

    def install(self):
        self.link_dist('alacritty.yml', '.config/alacritty/alacritty.yml')


def initializer():
    return Initializer
