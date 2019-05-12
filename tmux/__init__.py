from _src.initializer import BaseInitializer


class Initializer(BaseInitializer):
    TPM_PATH = ('.tmux', 'plugins', 'tpm')

    @property
    def requirements(self):
        return ['tmux']

    def build(self):
        tpm_path = self.home_path(*self.TPM_PATH)
        self.checkout(
            'https://github.com/tmux-plugins/tpm', tpm_path, absolute=True
        )
        self.inject('tmux.conf')

    def install(self):
        tpm_bin_path = self.TPM_PATH + ('bin',)
        self.link(self.dist_path('tmux.conf'), self.home_path('.tmux.conf'))
        self.run(self.home_path(*tpm_bin_path, 'install_plugins'))
        self.run(self.home_path(*tpm_bin_path, 'update_plugins'), 'all')


def initializer():
    return Initializer
