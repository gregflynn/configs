from _src.initializer import BaseInitializer


class Initializer(BaseInitializer):
    AUTOLOAD = ('.vim', 'autoload')
    AIRLINE_THEMES = AUTOLOAD + ('airline', 'themes')
    VIM_PLUG = 'vim-plug'

    @property
    def requirements(self):
        return ['vim-runtime']

    @property
    def install_in_cli(self):
        return True

    def build(self):
        self.mkdir(self.home_path(*self.AIRLINE_THEMES))
        self.checkout('https://github.com/junegunn/vim-plug.git', self.VIM_PLUG)

    def install(self):
        self.link(self.base_path('vimrc.vim'), self.home_path('.vimrc'))
        self.link(
            self.base_path('monokaipro.vim'),
            self.home_path(*(self.AIRLINE_THEMES + ('monokaipro.vim',)))
        )
        self.link(
            self.dist_path(self.VIM_PLUG, 'plug.vim'),
            self.home_path(*(self.AUTOLOAD + ('plug.vim',)))
        )
        self.run('vim +PlugUpdate +qall')


def initializer():
    return Initializer
