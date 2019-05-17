from _src.initializer import BaseInitializer


class Initializer(BaseInitializer):
    TPM_PATH = ('.tmux', 'plugins', 'tpm')

    @property
    def requirements(self):
        return ['tmux']

    def build(self):
        self.checkout('https://github.com/tmux-plugins/tpm', self._tpm_path)
        self.inject('tmux.conf')

    def install(self):
        tpm_bin_path = self._tpm_path + '/bin'
        self.link_dist('tmux.conf', '.tmux.conf')
        self.run(tpm_bin_path + '/install_plugins')
        self.run(tpm_bin_path + '/update_plugins' + ' all')

    @property
    def _tpm_path(self):
        return self.home_path(*self.TPM_PATH)


def initializer():
    return Initializer
