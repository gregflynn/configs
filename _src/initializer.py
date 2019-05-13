import os
from subprocess import check_call

from . import settings


class BaseInitializer(object):
    """Base initializer for modules
    """

    DIST = 'dist'

    INJECT_MAP = {
        'DS_HOME': settings.DOTSAN_HOME,
        'DS_LOCK': settings.DOTSAN_LOCK,
        'DS_WALLPAPER': settings.DOTSAN_WALLPAPER,

        'DS_BACKGROUND': settings.Colors.BACKGROUND,
        'DS_BLACK': settings.Colors.BLACK,
        'DS_GRAY': settings.Colors.GRAY,
        'DS_WHITE': settings.Colors.WHITE,

        'DS_BLUE': settings.Colors.BLUE,
        'DS_CYAN': settings.Colors.CYAN,
        'DS_GREEN': settings.Colors.GREEN,
        'DS_ORANGE': settings.Colors.ORANGE,
        'DS_PURPLE': settings.Colors.PURPLE,
        'DS_RED': settings.Colors.RED,
        'DS_YELLOW': settings.Colors.YELLOW
    }

    def __init__(self, name):
        """
        Args:
            name (str): Name of the module and its subdirectory
        """
        self.name = name
        self._dist_exists = None

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

    def checkout(self, repo, dest):
        """Clone or pull a remote repository

        Args:
            repo (str): git remote url passed to git clone
            dest (str): the path in the dist directory to clone to, or absolute
                path if the absolute flag is set to true
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
            inject_map (dict{str => str}): map of values to template in, uses
                default inject map if not supplied
        """
        self._assert_dist()
        infile = self.base_path(source)
        outfile = self.dist_path(source if dest is None else dest)
        self._assert_dir(outfile)

        with open(infile, 'r') as rf, open(outfile, 'w') as wf:
            for line in rf.readlines():
                wf.write(self._inject_line(line, inject_map or self.INJECT_MAP))

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
        if os.path.islink(link) and os.readlink(link) == points_to:
            # link already exists and is correct
            return

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

    #
    # Private helpers
    #

    @staticmethod
    def _inject_line(line, inject_map):
        for name, value in inject_map.items():
            holder = '{{{}}}'.format(name)
            line = line.replace(holder, value)
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
