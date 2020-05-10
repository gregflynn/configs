from sanity.initializer import BaseInitializer
from sanity.package_manager import PackageManager


class Initializer(BaseInitializer):
    VIM_PLUG = 'vim-plug'

    @property
    def requirements(self):
        return ['vim-runtime']

    def build(self):
        self.checkout(
            'https://github.com/junegunn/vim-plug.git', self.VIM_PLUG
        )

    def install(self):
        self.link_base('vimrc.vim', '.vimrc')
        self.link_base(
            'monokaipro.vim', '.vim/autoload/airline/themes/monokaipro.vim'
        )
        self.link_dist(self.VIM_PLUG + '/plug.vim', '.vim/autoload/plug.vim')
        self.run('vim +PlugUpdate +qall')

        if PackageManager().is_installed('neovim'):
            self.link_base('neovim.vim', '.config/nvim/init.vim')
            self.run('nvim +PlugUpdate +qall')
            self.shell_base('neovim.sh')
