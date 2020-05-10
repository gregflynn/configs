import os
from importlib import import_module

from .settings import module_path


class Module(object):
    def __init__(self, name):
        self.name = name

    def is_valid(self):
        full_path = module_path(self.name)
        return (
            os.path.isdir(full_path)
            and os.path.isfile(f'{full_path}/__init__.py')
        )

    def load(self, user):
        if not self.is_valid():
            raise Exception('Attempted to load an invalid module')

        module = import_module(f'modules.{self.name}')

        return module.Initializer(self.name, user)


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
