from sanity.initializer import BaseInitializer


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['kitty']

    def build(self):
        self.inject('kitty.conf')

    def install(self):
        self.link_dist('kitty.conf', '.config/kitty/kitty.conf')
        self.link_base('kittens', '.config/kitty/kittens')
