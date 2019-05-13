import os
import traceback
from getpass import getuser

from .logger import LogLevel, Logger
from .package_manager import PackageManager


class Installer(object):
    def __init__(self, modules):
        """
        Args:
            modules (list[Module]):
        """
        self._modules = modules

        self._is_root = getuser() == 'root'
        self._is_ssh = os.getenv('SSH_CLIENT') or os.getenv('SSH_TTY')
        self._is_cli_install = self._is_root or self._is_ssh

        self._pkger = PackageManager()

    def install(self):
        """Install all modules
        """
        for module in self._modules:
            self._install_module(module)

    def _install_module(self, module):
        """
        Args:
            module (Module):
        """
        logger = Logger(module.name)

        try:
            initializer = module.load()

            if not self._meets_requirements(initializer, logger):
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
        if self._is_cli_install and not initializer.install_in_cli:
            logger.log(LogLevel.WARN, "Not enabled in CLI-Only environment")
            return False

        missing_requirements = set()

        for requirement in initializer.requirements:
            if not self._pkger.is_installed(requirement):
                missing_requirements.add(requirement)

        if missing_requirements:
            logger.log(
                LogLevel.WARN,
                'Missing Packages: {}'.format(missing_requirements)
            )
            return False
        else:
            return True

