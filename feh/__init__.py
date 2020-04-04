from _src.initializer import BaseInitializer


# use "/usr/bin/feh -Tview --start-at" in thunar

class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['feh']

    def build(self):
        self.inject('themes', inject_map={
            'WIDTH': 1800,
            'HEIGHT': 1024,
        })

    def install(self):
        self.link_base('buttons', '.config/feh/buttons')
        self.link_base('keys', '.config/feh/keys')
        self.link_dist('themes', '.config/feh/themes')
        self.bin('thumb', '{} $@'.format(self.base_path('thumb.sh')))
        self.bin('img', '{} $@'.format(self.base_path('img.sh')))
