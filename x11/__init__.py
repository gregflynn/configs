from _src.initializer import BaseInitializer


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return [
            'lightdm',
            'ffmpeg',
            'xautolock',
            'i3lock-color',
            'compton'
        ]

    def build(self):
        self.inject('i3lock.sh')
        self.inject('xprofile.sh')

    def install(self):
        self.link_dist('xprofile.sh', '.xprofile')
