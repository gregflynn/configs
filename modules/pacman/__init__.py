from sanity.initializer import BaseInitializer
from sanity.settings import ExecWrapper


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['pacman']

    def install(self):
        self.bin('pac', self.base_path('pac.py'), bin_type=ExecWrapper.PYTHON)
        self.bin_autocomplete_click('pac')
