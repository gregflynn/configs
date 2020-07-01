import os
from importlib import import_module
from pathlib import Path

from sanity.settings import module_path


class Module(object):
    def __init__(self, name):
        self.name = name
        self.path = Path(module_path(name))

    def is_valid(self):
        return self.path.is_dir() and (self.path / '__init__.py').is_file()

    def is_remote(self):
        return (self.path / '.git').exists()

    def load(self, user, machine):
        if not self.is_valid():
            raise Exception('Attempted to load an invalid module')

        module = import_module(f'modules.{self.name}')

        return module.Initializer(self.name, user, machine)


class Modules(object):
    @classmethod
    def get_modules(cls):
        """Get a list of all python module names in the dotsanity home

        Returns:
            list[Module]: module directory names
        """
        modules = []

        for module_name in os.listdir(module_path('')):
            module = Module(module_name)
            if module.is_valid():
                modules.append(module)

        return sorted(modules, key=lambda m: m.name)
