from _src.initializer import BaseInitializer


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['systemd']

    @property
    def install_in_cli(self):
        return True

    def install(self):
        self.shell_base('sys.sh')


def initializer():
    return Initializer
