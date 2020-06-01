import os
from subprocess import check_call

from .settings import (
    home_path, module_path, dist_path, ExecWrapper, assert_dir,
    DOTSAN_SHELL_COMP_BASH, DOTSAN_SHELL_COMP_ZSH, DEFAULT_INJECT_MAP,
    DOTSAN_SHELL_SOURCES,
)
from .logger import Logger


DESKTOP_PATH = home_path('.local/share/applications')
DESKTOP_TEMPLATE = """
[Desktop Entry]
Type=Application
Version=1.0

Name={name}
Exec={exec}
Icon={icon}
"""


class BaseInitializer(object):
    """Base initializer for modules
    """
    def __init__(self, name, user):
        """
        Args:
            name (str): Name of the module and its subdirectory
        """
        self.user = user
        self.name = name
        self.logger = Logger(name)
        self._dist_exists = None
        self._shell_sources_exists = None

    #
    # Overrides
    #

    @property
    def requirements(self):
        """The list of required packages to initialize this module

        Returns:
            (list[str]) package names that need to be installed
        """
        return []

    @property
    def user_groups(self):
        """The list of required groups for the user to be in

        Returns:
            (list[str]) group names
        """
        return []

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
        return home_path(*extra)

    def base_path(self, *extra):
        return module_path(self.name, *extra)

    def dist_path(self, *extra):
        return dist_path(self.name, *extra)

    #
    # Public helpers
    #

    def bin(
            self, name: str, executable: str,
            bash_comp: str = None,
            zsh_comp: str = None,
            bin_type: ExecWrapper = ExecWrapper.BASH):
        """Add an executable to the path with shell completion support

        Args:
            name: name of the executable on the PATH
            executable: appended to the wrapper script to execute, this can be
                any bash required to start the executable
            bash_comp: absolute path to bash completions for this command
            zsh_comp: absolute path to zsh completions for this command
            bin_type: type of bin script, either python or bash
        """
        ExecWrapper.render(bin_type, executable, name)

        if bash_comp:
            self.link(
                bash_comp, os.path.join(DOTSAN_SHELL_COMP_BASH, name)
            )
        if zsh_comp:
            self.link(
                zsh_comp,
                os.path.join(DOTSAN_SHELL_COMP_ZSH, '_' + name)
            )

    def checkout(self, repo, dest):
        """Clone or pull a remote repository

        Args:
            repo (str): git remote url passed to git clone
            dest (str): the path in the dist directory to clone to, or absolute
                path to anywhere on disk
        """
        checkout_path = self._relative_dist_or_abs(dest)

        if os.path.isdir(checkout_path):
            check_call(['git', 'pull'], cwd=checkout_path)
        else:
            check_call(['git', 'clone', repo, checkout_path])

    def desktop(self, name: str, exec_path: str, icon_path: str = None):
        """Write a desktop entry to launch an application with

        Args:
            name: the name of application
            exec_path: path to the executable for the program
            icon_path: path to the icon for the program
        """
        assert_dir(self.home_path('.local/share/applications'))

        with open(os.path.join(DESKTOP_PATH, f'{name}.desktop'), 'w') as d:
            d.write(DESKTOP_TEMPLATE.format(
                name=name, exec=exec_path, icon=icon_path
            ))

    def download(self, url: str, dest: str):
        """Download a file

        Args:
            url: url to download
            dest: path to download the file to, either absolute or relative to
                the module dist folder
        """
        download_path = self._relative_dist_or_abs(dest)

        if not os.path.exists(download_path):
            check_call(['curl', url, '-o', download_path])

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
        assert_dir(outfile)

        final_inject_map = {}
        final_inject_map.update(DEFAULT_INJECT_MAP)
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
        assert_dir(link)
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

        self.link(points_to, os.path.join(DOTSAN_SHELL_SOURCES, name))

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

    def _relative_dist_or_abs(self, path):
        absolute = os.path.isabs(path)
        if absolute:
            assert_dir(path)
        else:
            self._assert_dist()

        return path if absolute else self.dist_path(path)
