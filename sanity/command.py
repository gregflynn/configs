import os
import shutil
from time import sleep
from subprocess import check_call, CalledProcessError

import click
from tabulate import tabulate

from sanity import settings
from sanity.installer import Installer
from sanity.machine import Machine
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
    check_call(['pip', 'install', '-q', '-e', '.'])
    modules = Modules.get_modules()

    if module is not None:
        modules = [m for m in modules if m.name == module]

    installer = Installer(modules)
    installer.install()


@dotsan.command()
@click.pass_context
def update(ctx):
    """Update to latest
    """
    os.chdir(settings.DOTSAN_HOME)
    try:
        check_call(['git', 'pull'])
    except CalledProcessError:
        click.secho(f'sanity is dirty', fg='red', err=True)
        return

    for module in Modules.get_modules():
        if module.is_remote():
            os.chdir(module.path)
            try:
                check_call(['git', 'pull'])
            except CalledProcessError:
                click.secho(f'{module.name} is dirty', fg='red', err=True)
                return

    ctx.invoke(install)


@dotsan.command()
def status():
    """Show status of dotsanity modules
    """
    data = []
    machine = Machine()

    y = click.style('y', fg='green')
    n = click.style('n', fg='red')

    for module in Modules.get_modules():
        data.append((module.name,
                     y if machine.is_module_enabled(module) else n,
                     y if module.is_remote() else n))

    click.echo(tabulate(data, headers=['Module', 'Enabled', 'Remote']))
    click.echo()
    click.echo(tabulate(list(machine.get_settings().items()),
                        headers=['Setting', 'Value']))


@dotsan.command()
@click.argument('module_name')
def enable(module_name):
    """Enable a modules
    """
    for module in Modules.get_modules():
        if module.name == module_name:
            Machine().enable_module(module)
            return

    click.echo(f'No module named {module_name} found.')


@dotsan.command()
@click.argument('module_name')
def disable(module_name):
    """Disable a modules
    """
    for module in Modules.get_modules():
        if module.name == module_name:
            Machine().disable_module(module)
            return

    click.echo(f'No module named {module_name} found.')


@dotsan.command()
@click.argument('name')
@click.option('--value', help='Set the setting to this value')
@click.option('--delete/--no-delete', help='Delete the setting')
def setting(name, value=None, delete=False):
    """Get, set/update, or delete settings
    """
    machine = Machine()

    if delete:
        machine.delete_setting(name)
    elif value is not None:
        machine.set_setting_value(name, value)
    else:
        value = machine.get_setting_value(name)
        if value is not None:
            click.echo(value)


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
