from _src import settings
from _src.initializer import BaseInitializer


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return [
            'awesome',
            'gpmdp',
            'lain-git',
            'vicious',
            'redshift',
            'flameshot',
            'xsel',
            'rofimoji-git'
        ]

    def build(self):
        self.inject('theme.lua')

    def install(self):
        self.link_base('mirror', '.config/awesome')

        # HACK: this symlink is git-ignored
        self.link_dist('theme.lua', '.config/awesome/theme.lua')

        self.run("""
            flameshot config \
                    --maincolor "#{}" \
                    --contrastcolor "#{}" \
                    --showhelp false \
                    --trayicon false
        """.format(settings.Colors.ORANGE, settings.Colors.BACKGROUND))


def initializer():
    return Initializer
