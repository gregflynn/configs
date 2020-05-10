import os
import traceback
from subprocess import check_output

from .logger import LogLevel, Logger
from .machine import Machine
from .package_manager import PackageManager


class Installer(object):
    def __init__(self, modules):
        """
        Args:
            modules (list[Module]):
        """
        self._modules = modules

        self._user = check_output('whoami').decode('utf-8').strip()
        self._groups = set(
            check_output('groups').decode('utf-8').strip().split())

        self._is_root = self._user == 'root'
        self._is_ssh = os.getenv('SSH_CLIENT') or os.getenv('SSH_TTY')
        self._is_cli_install = self._is_root or self._is_ssh

        self._pkger = PackageManager()
        self._machine = Machine()

    def install(self):
        """Install all modules
        """
        for module in self._modules:
            self._install_module(module)
        self._machine.save()

    def _install_module(self, module):
        """
        Args:
            module (Module):
        """
        logger = Logger(module.name)

        try:
            initializer = module.load(self._user)

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
            logger.log(LogLevel.ERROR, e)
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
