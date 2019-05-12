import os
import traceback
from getpass import getuser
from subprocess import check_call, CalledProcessError, Popen, PIPE, DEVNULL

from .logger import LogLevel, Logger


class PackageManager(object):
    def __init__(self):
        try:
            pacman = ['pacman', '-Q']
            check_call(pacman, stdout=DEVNULL, stderr=DEVNULL)
            self._query_cmd = pacman
            self._grep_template = '^{} '
        except CalledProcessError:
            self._query_cmd = ['dpkg', '-l']
            self._grep_template = ' {} '

    def is_installed(self, package):
        query = Popen(self._query_cmd, stdout=PIPE)

        try:
            check_call(
                ['grep', self._grep_template.format(package)],
                stdin=query.stdout,
                stdout=DEVNULL,
                stderr=DEVNULL
            )
            query.wait()
            return True
        except CalledProcessError:
            return False


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

