from _src.initializer import BaseInitializer


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['task']

    @property
    def install_in_cli(self):
        return True

    def build(self):
        self.inject('taskrc', inject_map={
            'TASK_THEME': self.base_path('tasks.theme')
        })

    def install(self):
        self.shell_base('tasks.sh')
        self.link_dist('taskrc', '.taskrc')


def initializer():
    return Initializer
