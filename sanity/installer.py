import traceback

from sanity.settings import ExecWrapper
from sanity.initializer import BaseInitializer
from sanity.logger import LogLevel, Logger
from sanity.machine import Machine
from sanity.package_manager import PackageManager
from sanity.util.shell import get_output


class Installer(object):
    def __init__(self, modules):
        """
        Args:
            modules (list[Module]):
        """
        self._modules = modules

        self._user = get_output('whoami').strip()
        self._groups = set(get_output('groups').strip().split())

        self._pkger = PackageManager()
        self._machine = Machine()

    def install(self):
        """Install all modules
        """
        for module in self._modules:
            self._install_module(module)
        self._install_dotsan()

    def _install_dotsan(self):
        initializer = BaseInitializer('sanity', self._user, self._machine)
        initializer.bin('dotsan', 'dotsan', bin_type=ExecWrapper.NONE)
        initializer.bin_autocomplete_click('dotsan')

    def _install_module(self, module):
        """
        Args:
            module (Module):
        """
        logger = Logger(module.name)

        try:
            initializer = module.load(self._user, self._machine)

            if not self._machine.is_module_configured(module):
                if logger.prompt('Enable Module?'):
                    self._machine.enable_module(module)
                else:
                    self._machine.disable_module(module)

            if (
                not self._machine.is_module_enabled(module)
                or not self._meets_requirements(initializer, logger)
            ):
                return

            initializer.build()
            initializer.install()

            logger.log(LogLevel.OK)
        except Exception as e:
            logger.log(LogLevel.ERROR, str(e))
            print(traceback.format_exc())

    def _meets_requirements(self, initializer, logger):
        """
        Args:
            initializer (BaseInitializer):
        """
        missing_requirements = {
            requirement
            for requirement in initializer.requirements
            if not self._pkger.is_installed(requirement)
        }

        if missing_requirements:
            logger.warn(
                'Missing Packages: {}'.format(missing_requirements)
            )
            return False

        missing_groups = {
            req_group
            for req_group in initializer.user_groups
            if req_group not in self._groups
        }

        if missing_groups:
            logger.warn("""
                User not in '{}' group(s).
                $ sudo usermod -a -G GROUP {}
            """.format(missing_groups, self._user))
            return False

        return True
