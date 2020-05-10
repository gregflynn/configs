
import json
import os

from .settings import ds_path


MACHINE_JSON = ds_path('machine.json')


class Machine(object):
    def __init__(self):
        if os.path.exists(MACHINE_JSON):
            with open(MACHINE_JSON, 'r') as f:
                self._machine = json.loads(f.read())
        else:
            self._machine = {}

    def save(self):
        with open(MACHINE_JSON, 'w') as f:
            f.write(json.dumps(self._machine, sort_keys=True, indent=4))

    def is_module_configured(self, module):
        return module.name in self._machine

    def is_module_enabled(self, module):
        return (self._machine.get(module.name) or {}).get('enabled', False)

    def enable_module(self, module):
        if module.name not in self._machine:
            self._machine[module.name] = {}

        self._machine[module.name]['enabled'] = True

    def disable_module(self, module):
        if module.name not in self._machine:
            self._machine[module.name] = {}

        self._machine[module.name]['enabled'] = False
