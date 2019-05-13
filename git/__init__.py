from _src.initializer import BaseInitializer


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['git']

    @property
    def install_in_cli(self):
        return True

    def install(self):
        self.link_base('gitconfig', '.gitconfig')
        self.link_base('gitignore', '.gitignore')
        self.shell_base('git.sh')


def initializer():
    return Initializer
