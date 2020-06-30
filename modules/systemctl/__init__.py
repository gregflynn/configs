from sanity.initializer import BaseInitializer
from sanity.settings import ExecWrapper


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['systemd']

    def install(self):
        self.bin('sys', self.base_path('sys.py'), bin_type=ExecWrapper.PYTHON)
