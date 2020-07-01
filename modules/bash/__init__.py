from sanity.initializer import BaseInitializer
from sanity.settings import module_path


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['bash']

    def build(self):
        self.inject('aliases.sh')
        self.inject('bashrc.sh', inject_map={
            'ALIASES': self.dist_path('aliases.sh'),
            'PROMPT': module_path('zsh', 'prompt.zsh')})

    def install(self):
        self.link_dist('bashrc.sh', '.bashrc')
