from sanity import settings
from sanity.initializer import BaseInitializer
from sanity.settings import module_path


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['awesome', 'flameshot', 'peek', 'redshift', 'rofi', 'vicious',
                'xsel']

    @property
    def user_groups(self):
        return ['video']

    def build(self):
        self.inject('dstheme.lua', inject_map={
            'DS_WALLPAPER': (self.machine.get_setting_value('DS_WALLPAPER')
                             or module_path('private', 'wallpapers',
                                            '10-12.jpg'))})
        self.checkout('https://github.com/xinhaoyuan/layout-machi.git',
                      'layout-machi')
        self.checkout('https://github.com/lcpz/lain.git', 'lain')

    def install(self):
        self.link_base('rc.lua', '.config/awesome/rc.lua')
        self.link_dist('dstheme.lua', '.config/awesome/dstheme.lua')

        self.link_base('sanity', '.config/awesome/sanity')
        self.link_dist('layout-machi', '.config/awesome/layout-machi')
        self.link_dist('lain', '.config/awesome/lain')

        self.run("""
            flameshot config \
                    --maincolor "#{}" \
                    --contrastcolor "#{}" \
                    --showhelp false \
                    --trayicon false
        """.format(settings.Colors.YELLOW, settings.Colors.BACKGROUND))

        self.link_base('redshift.conf', '.config/redshift/redshift.conf')
