import sys
import json


class AurPackage(object):
    PKG_TEMPLATE = "aur/{name} {version}\n    {description}"

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

    def print_description(self):
        print(self.PKG_TEMPLATE.format(
            name=self.name, version=self.version, description=self.description
        ))


if __name__ == '__main__':
    js = json.load(sys.stdin)

    if len(js['results']):
        for j in sorted(js['results'], key=lambda x: x['Name']):
            AurPackage(j).print_description()
    else:
        print('Not Found')
