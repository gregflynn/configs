import os

from _src import settings
from _src.initializer import BaseInitializer


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['task']

    def build(self):
        taskd = settings.ds_path('private', 'taskd', 'taskd_client')
        taskd = 'include {}'.format(taskd) if os.path.isfile(taskd) else ''
        self.inject('taskrc', inject_map={
            'TASK_THEME': self.base_path('tasks.theme'),
            'TASKD': taskd
        })
        self.checkout('git@github.com:gregflynn/taskqm.git', 'taskqm')

    def install(self):
        self.shell_base('tasks.sh')
        self.link_dist('taskrc', '.taskrc')
        self.bin('taskqm', self.dist_path('taskqm/taskqm'))
