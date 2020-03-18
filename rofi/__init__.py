from _src.initializer import BaseInitializer


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['rofi', 'rofi-calc', 'rofimoji', 'rofi-pass', 'networkmanager']

    def build(self):
        self.inject('rofi-theme.rasi')

    def install(self):
        config = '.config/rofi/'
        self.link_base('rofi.config', config + 'config')
        self.link_dist('rofi-theme.rasi', config + 'dotsanity.rasi')
        self.link_base('config.ini', '.config/networkmanager-dmenu/config.ini')
