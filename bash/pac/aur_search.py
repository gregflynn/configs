import sys
import json
from subprocess import check_output


INSTALLED_AUR_PKGS = set()


class AurPackage(object):
    def __init__(self, data):
        self._data = data

    @property
    def name(self):
        return self._data['Name']

    @property
    def version(self):
        return self._data['Version']

    @property
    def description(self):
        desc_len = len(self._data['Description'] or [])
        return (self._data['Description']
                if desc_len < 75 else self._data['Description'][:75] + '...')

    @property
    def installed(self):
        return self.name in INSTALLED_AUR_PKGS

    def print_description(self):
        name = f'\033[33m{self.name}\033[0m'
        src = '\033[2m(aur)\033[0m'
        installed = '\033[32m[installed]\033[0m' if self.installed else ''
        print(f'{name} {src} {self.version} {installed}\n    {self.description}')


if __name__ == '__main__':
    js = json.load(sys.stdin)
    aur_home = sys.argv[1]
    INSTALLED_AUR_PKGS = {
        p.strip() for p in check_output(['ls', aur_home]).decode(encoding='UTF-8').split()
    }

    if len(js['results']):
        for j in sorted(js['results'], key=lambda x: x['Name']):
            AurPackage(j).print_description()
    else:
        print('Not Found')
