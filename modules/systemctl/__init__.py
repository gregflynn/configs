from sanity.initializer import BaseInitializer


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['systemd']

    def install(self):
        self.bin(
            'sys',
            '. {}\n__sys $@'.format(self.base_path('sys.sh')),
            bash_comp=self.base_path('sys-completions.bash'),
            zsh_comp=self.base_path('sys-completions.zsh')
        )
