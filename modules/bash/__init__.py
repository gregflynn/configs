from sanity.initializer import BaseInitializer


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['bash']

    def build(self):
        self.inject('bashrc.sh')

    def install(self):
        self.link_dist('bashrc.sh', '.bashrc')
