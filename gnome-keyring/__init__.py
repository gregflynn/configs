from _src.initializer import BaseInitializer


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['gnome-keyring']

    def install(self):
        self.shell_base('gnome_keyring.sh')
