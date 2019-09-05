import os
import stat
from subprocess import check_call

from . import settings
from .logger import Logger


class BaseInitializer(object):
    """Base initializer for modules
    """
    def __init__(self, name):
        """
        Args:
            name (str): Name of the module and its subdirectory
        """
        self.name = name
        self.logger = Logger(name)
        self._dist_exists = None
        self._shell_sources_exists = None

    #
    # Overrides
    #

    @property
    def requirements(self):
        """Get the list of required packages to initialize this module

        Returns:
            list[str]: package names that need to be installed
        """
        return []

    @property
    def install_in_cli(self):
        """Return true to indicate this module applies to CLI-only environments

        Returns:
            bool:
        """
        return False

    def build(self):
        """Build phase of initialization
        """

    def install(self):
        """Installation phase of initialization
        """

    #
    # Path Helpers
    #

    @staticmethod
    def home_path(*extra):
        return settings.home_path(*extra)

    def base_path(self, *extra):
        return settings.module_path(self.name, *extra)

    def dist_path(self, *extra):
        return settings.dist_path(self.name, *extra)

    #
    # Public helpers
    #

    def bin(self, name, executable, bash_comp=None, zsh_comp=None):
        """Add an executable to the path with shell completion support

        Args:
            name (str): name of the executable on the PATH
            executable (str): appended to the wrapper script to execute, this
                can be any bash required to start the executable
            bash_comp (str): absolute path to bash completions for this command
            zsh_comp (str): absolute path to zsh completions for this command
        """
        bin_path = os.path.join(settings.DOTSAN_SHELL_BIN, name)
        self._assert_dir(bin_path)
        with open(bin_path, 'w') as ex:
            ex.write(settings.BIN_WRAPPERS['default'])
            ex.write(executable)
        os.chmod(bin_path, stat.S_IRWXU)

        if bash_comp:
            self.link(
                bash_comp, os.path.join(settings.DOTSAN_SHELL_COMP_BASH, name)
            )
        if zsh_comp:
            self.link(
                zsh_comp,
                os.path.join(settings.DOTSAN_SHELL_COMP_ZSH, '_' + name)
            )

    def checkout(self, repo, dest):
        """Clone or pull a remote repository

        Args:
            repo (str): git remote url passed to git clone
            dest (str): the path in the dist directory to clone to, or absolute
                path to anywhere on disk
        """
        absolute = os.path.isabs(dest)
        if absolute:
            self._assert_dir(dest)
        else:
            self._assert_dist()

        checkout_path = dest if absolute else self.dist_path(dest)

        if os.path.isdir(checkout_path):
            check_call(['git', 'pull'], cwd=checkout_path)
        else:
            check_call(['git', 'clone', repo, checkout_path])

    def inject(self, source, dest=None, inject_map=None):
        """Inject variables into a configuration file

        Args:
            source (str): name of the template file to read
            dest (str): name of the file to write in dist/, omit for the same
                name as the source file
            inject_map (dict{str => str}): map of values to template in, in
                addition to the default template map values
        """
        self._assert_dist()
        infile = self.base_path(source)
        outfile = self.dist_path(source if dest is None else dest)
        self._assert_dir(outfile)

        final_inject_map = {}
        final_inject_map.update(settings.DEFAULT_INJECT_MAP)
        final_inject_map.update(inject_map or {})

        with open(infile, 'r') as rf, open(outfile, 'w') as wf:
            for line in rf.readlines():
                wf.write(self._inject_line(line, final_inject_map))

    @classmethod
    def link(cls, points_to, link_location):
        """Create a symlink

        Args:
            points_to (str): the absolute path the link points to
            link_location (str): the absolute path, or relative within HOME,
                where the link will reside on the filesystem
        """
        link = (
            link_location
            if os.path.isabs(link_location)
            else cls.home_path(link_location)
        )
        cls._assert_dir(link)
        if os.path.islink(link):
            if os.readlink(link) == points_to:
                # link already exists and is correct
                return
            else:
                os.remove(link)

        os.symlink(points_to, link)

    def link_base(self, points_to_from_base, link_location):
        """Create a symlink from the module base

        Args:
            points_to_from_base (str):
            link_location (str):
        """
        self.link(self.base_path(points_to_from_base), link_location)

    def link_dist(self, points_to_from_dist, link_location):
        """Create a symlink from the module base

        Args:
            points_to_from_dist (str):
            link_location (str):
        """
        self.link(self.dist_path(points_to_from_dist), link_location)

    @staticmethod
    def mkdir(path):
        """Make directories

        Args:
            path (str): path to create
        """
        os.makedirs(path, exist_ok=True)

    @staticmethod
    def run(*command, cwd=None):
        """Run a command
        """
        check_call(command, cwd=cwd, shell=True)

    def shell_source(self, points_to, init=False):
        """Register a source script that the configured shell should source

        Args:
            points_to (str): absolute path to the source script to register
            init (bool): Set to true to ensure this script is loaded before
                non-init scripts
        """
        name = os.path.basename(points_to)

        if init:
            name = '00_' + name

        self.link(points_to, os.path.join(settings.DOTSAN_SHELL_SOURCES, name))

    def shell_base(self, points_to_from_base, init=False):
        """Register a source script that the configured shell should source

        Args:
            points_to_from_base (str): path from base to the source script to
                register
            init (bool): Set to true to ensure this script is loaded before
                non-init scripts
        """
        self.shell_source(self.base_path(points_to_from_base), init=init)

    def shell_dist(self, points_to_from_dist, init=False):
        """Register a source script that the configured shell should source

        Args:
            points_to_from_dist (str): path from dist to the source script to
                register
            init (bool): Set to true to ensure this script is loaded before
                non-init scripts
        """
        self.shell_source(self.dist_path(points_to_from_dist), init=init)

    #
    # Private helpers
    #

    @staticmethod
    def _inject_line(line, inject_map):
        for name, value in inject_map.items():
            holder = '{{{}}}'.format(name)
            line = line.replace(holder, str(value))
        return line

    def _assert_dist(self):
        if not self._dist_exists:
            self.mkdir(self.dist_path())
            self._dist_exists = True

    @classmethod
    def _assert_dir(cls, path):
        dir_path = os.path.dirname(path)
        if not os.path.exists(dir_path):
            cls.mkdir(dir_path)
