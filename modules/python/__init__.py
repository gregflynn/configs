from sanity.initializer import BaseInitializer


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['python']

    def install(self):
        self.shell_base('python.sh')
