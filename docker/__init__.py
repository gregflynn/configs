from _src.initializer import BaseInitializer


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['docker']

    @property
    def user_groups(self):
        return ['docker']

    def install(self):
        self.bin(
            'dock',
            'source {}\n__dock $@'.format(self.base_path('dock.sh')),
            bash_comp=self.base_path('dock-completions.bash'),
            zsh_comp=self.base_path('dock-completions.zsh')
        )
