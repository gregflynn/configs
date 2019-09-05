from _src.initializer import BaseInitializer


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['networkmanager-dmenu-git']

    def install(self):
        self.link_base('config.ini', '.config/networkmanager-dmenu/config.ini')
