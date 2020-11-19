from sanity.initializer import BaseInitializer


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['ipython']

    def build(self):
        self.inject('ipython_config.py')

    def install(self):
        self.link_dist('ipython_config.py',
                       '.ipython/profile_default/ipython_config.py')
