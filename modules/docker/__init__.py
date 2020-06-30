from sanity.initializer import BaseInitializer
from sanity.settings import ExecWrapper


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['docker']

    @property
    def user_groups(self):
        return ['docker']

    def install(self):
        self.bin('dock', self.base_path('dock.py'),
                 bin_type=ExecWrapper.PYTHON)
