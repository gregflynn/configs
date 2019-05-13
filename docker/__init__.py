from _src.initializer import BaseInitializer


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['docker']

    @property
    def install_in_cli(self):
        return True

    def install(self):
        self.shell_base('dock.sh')


def initializer():
    return Initializer
