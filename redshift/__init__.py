from _src.initializer import BaseInitializer


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['redshift']

    def install(self):
        self.link_base('redshift.conf', '.config/redshift/redshift.conf')


def initializer():
    return Initializer
