from _src.initializer import BaseInitializer


class Initializer(BaseInitializer):
    VIM_PLUG = 'vim-plug'

    @property
    def requirements(self):
        return ['vim-runtime']

    @property
    def install_in_cli(self):
        return True

    def build(self):
        self.checkout('https://github.com/junegunn/vim-plug.git', self.VIM_PLUG)

    def install(self):
        self.link_base('vimrc.vim', '.vimrc')
        self.link_base(
            'monokaipro.vim', '.vim/autoload/airline/themes/monokaipro.vim'
        )
        self.link_dist(self.VIM_PLUG + '/plug.vim', '.vim/autoload/plug.vim')
        self.run('vim +PlugUpdate +qall')


def initializer():
    return Initializer
