from _src.initializer import BaseInitializer


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['python']

    def install(self):
        self.shell_base('python.sh')
        self.bin('charm', '{} $@'.format(self.base_path('charm.sh')))
