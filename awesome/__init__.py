from _src import settings
from _src.initializer import BaseInitializer


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return [
            'awesome',
            'lain-git',
            'vicious',
            'redshift',
            'flameshot',
            'peek',
            'xsel',
            'rofi'
        ]

    @property
    def user_groups(self):
        return ['video']

    def build(self):
        self.inject('theme.lua')
        self.checkout(
            'https://github.com/xinhaoyuan/layout-machi.git', 'layout-machi'
        )

    def install(self):
        self.link_base('mirror', '.config/awesome')

        # HACK: this symlink is git-ignored
        self.link_dist('theme.lua', '.config/awesome/theme.lua')

        # HACK: this symlink is also git ignored
        self.link_dist('layout-machi', '.config/awesome/layout-machi')

        self.run("""
            flameshot config \
                    --maincolor "#{}" \
                    --contrastcolor "#{}" \
                    --showhelp false \
                    --trayicon false
        """.format(settings.Colors.YELLOW, settings.Colors.BACKGROUND))
