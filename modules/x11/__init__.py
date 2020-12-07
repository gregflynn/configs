from sanity.initializer import BaseInitializer


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return [
            'lightdm',
            'xautolock',
            'i3lock-color',
            ('picom', 'compton'),
        ]

    def build(self):
        self.inject('i3lock.sh')
        self.inject('xprofile.sh')

    def install(self):
        self.link_dist('xprofile.sh', '.xprofile')
        self.link_base('xmodmap', '.Xmodmap')
