from _src.initializer import BaseInitializer


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['bash']

    @property
    def install_in_cli(self):
        return True

    def build(self):
        self.inject('bashrc.sh')

    def install(self):
        self.link_dist('bashrc.sh', '.bashrc')


def initializer():
    return Initializer
