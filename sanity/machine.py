
import dataset

from sanity.settings import ds_config_path


DATABASE_PATH = ds_config_path('machine.db')


class Machine(object):
    def __init__(self):
        self._db = dataset.connect(f'sqlite:///{DATABASE_PATH}')

    @property
    def _modules_db(self):
        return self._db['modules']

    @property
    def _settings_db(self):
        return self._db['settings']

    def is_module_configured(self, module):
        module_entry = self._modules_db.find_one(name=module.name)
        return module_entry is not None

    def is_module_enabled(self, module):
        module_entry = self._modules_db.find_one(name=module.name)
        return module_entry is not None and module_entry['enabled'] is True

    def enable_module(self, module):
        self._modules_db.upsert({'name': module.name, 'enabled': True},
                                ['name'])

    def disable_module(self, module):
        self._modules_db.upsert({'name': module.name, 'enabled': False},
                                ['name'])

    def get_settings(self):
        return {s['name']: s['value'] for s in self._settings_db.all()}

    def get_setting_value(self, name):
        row = self._settings_db.find_one(name=name)
        if row is None:
            return None
        else:
            return row['value']

    def set_setting_value(self, name, value):
        self._settings_db.upsert({'name': name, 'value': value}, ['name'])

    def delete_setting(self, name):
        if name:
            self._settings_db.delete(name=name)
