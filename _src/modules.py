import os
from importlib import import_module

from . import settings


class Module(object):
    def __init__(self, name):
        self.name = name

    def is_valid(self):
        full_path = self._full_path
        return (
            self.name != '_src'
            and os.path.isdir(full_path)
            and os.path.isfile('{}/__init__.py'.format(full_path))
        )

    def load(self):
        if not self.is_valid():
            raise Exception('Attempted to load an invalid module')

        module = import_module(self.name)

        return module.initializer()(self.name)

    @property
    def _full_path(self):
        return '{}/{}'.format(settings.DOTSAN_HOME, self.name)


class Modules(object):
    @classmethod
    def get_modules(cls):
        """Get a list of all python module names in the dotsanity home

        Returns:
            list[Module]: module directory names
        """
        modules = []

        for module_name in os.listdir(settings.DOTSAN_HOME):
            module = Module(module_name)
            if module.is_valid():
                modules.append(module)

        return sorted(modules, key=lambda m: m.name)
