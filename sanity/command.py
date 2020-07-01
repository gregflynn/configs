import os
import shutil
from time import sleep
from subprocess import check_call, CalledProcessError

import click

from sanity import settings
from sanity.installer import Installer
from sanity.modules import Modules
from sanity.settings import dist_path, DOTSAN_SHELL_BIN, DOTSAN_SHELL_COMP, \
    DOTSAN_SHELL_SOURCES


@click.group()
def dotsan():
    """Commands for managing dotsanity itself
    """


@dotsan.command()
@click.argument('module', required=False)
@click.option('--clean/--no-clean', default=False)
def install(module=None, clean=False):
    """(Re)Install local modules
    """
    if clean:
        shutil.rmtree(dist_path(''))
        shutil.rmtree(DOTSAN_SHELL_BIN)
        shutil.rmtree(DOTSAN_SHELL_COMP)
        shutil.rmtree(DOTSAN_SHELL_SOURCES)

    os.chdir(settings.DOTSAN_HOME)
    modules = Modules.get_modules()

    if module is not None:
        modules = [m for m in modules if m.name == module]

    installer = Installer(modules)
    installer.install()


@dotsan.command()
def update():
    """Update to latest
    """
    os.chdir(settings.DOTSAN_HOME)
    try:
        check_call(['git', 'pull'])
    except CalledProcessError:
        return

    for module in Modules.get_modules():
        if module.is_remote():
            os.chdir(module.path)
            check_call(['git', 'pull'])

    install()


@dotsan.command()
@click.argument('module')
@click.option('--time', type=int, default=2,
              help='Number of seconds between installs')
def watch(module, time):
    """Reinstall a module in a loop
    """

    while True:
        check_call(['date'])
        install(module)
        sleep(time)
