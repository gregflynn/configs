from _src.initializer import BaseInitializer


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['pacman']

    @property
    def install_in_cli(self):
        return True

    def install(self):
        self.shell_base('is_aur_pkg.sh', init=True)
        self.shell_base('aur.sh')
        self.shell_base('pacman.sh')


def initializer():
    return Initializer
