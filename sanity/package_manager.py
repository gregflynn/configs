from pathlib import Path
from subprocess import check_call, DEVNULL, CalledProcessError, PIPE, Popen


class PackageManager(object):
    def __init__(self):
        try:
            pacman = ['pacman', '-Q']
            check_call(pacman, stdout=DEVNULL, stderr=DEVNULL)
            self._query_cmd = pacman
            self._grep_template = '^{} '
        except (CalledProcessError, FileNotFoundError):
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
            pass

        # if the package wasn't installed via package manager, check for it in the git
        # dir for manual installs
        return (Path.home() / 'git' / package).is_dir()
