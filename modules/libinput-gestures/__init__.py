from sanity.initializer import BaseInitializer


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['libinput-gestures', 'xdotool']

    @property
    def user_groups(self):
        return ['input']

    def install(self):
        self.link_base(
            'libinput-gestures.conf', '.config/libinput-gestures.conf')
        self.run('libinput-gestures-setup restart')
