from _src.initializer import BaseInitializer


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['systemd']

    @property
    def install_in_cli(self):
        return True

    def install(self):
        self.bin(
            'sys',
            '. {}\n__sys $@'.format(self.base_path('sys.sh')),
            bash_comp=self.base_path('sys-completions.bash'),
            zsh_comp=self.base_path('sys-completions.zsh')
        )
