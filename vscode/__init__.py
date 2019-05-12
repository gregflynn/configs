from subprocess import check_output

from _src.initializer import BaseInitializer


class Initializer(BaseInitializer):
    USER_DIR = ('.config', 'Code', 'User')

    @property
    def requirements(self):
        return ['visual-studio-code-bin']

    def install(self):
        def user(suffix):
            return self.USER_DIR + (suffix,)

        self.mkdir(self.home_path(*self.USER_DIR))
        self.link(self.base_path('ctags'), self.home_path('.ctags'))

        self.link(
            self.base_path('User', 'snippets'),
            self.home_path(*user('snippets'))
        )
        self.link(
            self.base_path('User', 'keybindings.json'),
            self.home_path(*user('keybindings.json'))
        )
        self.link(
            self.base_path('User', 'settings.json'),
            self.home_path(*user('settings.json'))
        )
        self._sync_extensions()

    def _sync_extensions(self):
        dotsanity = self._get_extensions_whitelist()
        installed = self._get_installed_extensions()

        # extensions to remove
        for del_extension in installed - dotsanity:
            self._uninstall_extension(del_extension)

        # extensions to install
        for ins_extension in dotsanity - installed:
            self._install_extension(ins_extension)

    def _get_extensions_whitelist(self):
        extensions = set()
        with open(self.base_path('extensions'), 'r') as f:
            for extension in f.readlines():
                extensions.add(extension.strip())
        return extensions

    @staticmethod
    def _get_installed_extensions():
        output = check_output(['code', '--list-extensions']).decode('utf-8')
        return {ext for ext in output.split('\n') if ext}

    def _install_extension(self, extension):
        self.run('code --install-extension {}'.format(extension))

    def _uninstall_extension(self, extension):
        self.run('code --uninstall-extension {}'.format(extension))


def initializer():
    return Initializer
