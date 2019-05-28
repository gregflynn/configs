import os

from _src import settings
from _src.initializer import BaseInitializer


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['task']

    @property
    def install_in_cli(self):
        return True

    def build(self):
        taskd = settings.ds_path('private', 'taskd', 'taskd_client')
        taskd = 'include {}'.format(taskd) if os.path.isfile(taskd) else ''
        self.inject('taskrc', inject_map={
            'TASK_THEME': self.base_path('tasks.theme'),
            'TASKD': taskd
        })

    def install(self):
        self.shell_base('tasks.sh')
        self.link_dist('taskrc', '.taskrc')


def initializer():
    return Initializer
