import os
from subprocess import check_output

from _src.initializer import BaseInitializer


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return [
            'thunar',
            'thunar-archive-plugin',
            'thunar-media-tags-plugin',
            'thunar-volman'
        ]

    def build(self):
        install_root = os.path.join(
            os.getenv('HOME'),
            '.local/share/JetBrains/Toolbox/apps/PyCharm-P/ch-0'
        )
        version = check_output(
            f'ls {install_root} | grep -v plugins | grep -v vmoptions | tail -n 1',
            shell=True
        ).decode('utf8').strip() or ''
        self.inject(
            'uca.xml',
            inject_map={'DS_CHARM': f'{install_root}/{version}/bin/pycharm.sh'}
        )

    def install(self):
        self.link_dist('uca.xml', '.config/Thunar/uca.xml')
