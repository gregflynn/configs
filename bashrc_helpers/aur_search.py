import os
import sys
import json


INSTALLED_PACKAGES = set(os.listdir(os.environ['HOME'] + '/aur'))


class AurPackage(object):
    PKG_TEMPLATE = "aur/{name} {version} {i}\n    {description}"

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
        l = len(self._data['Description'])
        return (self._data['Description']
                if l < 75 else self._data['Description'][:75] + '...')

    @property
    def installed(self):
        return self.name in INSTALLED_PACKAGES

    def print_description(self):
        print(self.PKG_TEMPLATE.format(
            name=self.name, version=self.version, description=self.description,
            i="[installed]" if self.installed else ""))


if __name__ == '__main__':
    js = json.load(sys.stdin)

    if len(js['results']):
        for j in sorted(js['results'], key=lambda x: x['Name']):
            AurPackage(j).print_description()
    else:
        print('Not Found')
