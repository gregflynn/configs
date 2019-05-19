from _src.initializer import BaseInitializer


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['bash']

    @property
    def install_in_cli(self):
        return True

    def build(self):
        self.inject('vars.sh')

    def install(self):
        self.shell_base('colors.sh', init=True)
        self.shell_dist('vars.sh', init=True)
        self.bin(
            'dotsan',
            '. {}; __dotsan $@'.format(self.base_path('dotsan.sh'))
        )


def initializer():
    return Initializer
