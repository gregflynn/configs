from sanity.initializer import BaseInitializer


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['git']

    def install(self):
        self.link_base('gitconfig', '.gitconfig')
        self.link_base('gitignore', '.gitignore')
        self.shell_base('git.sh')
