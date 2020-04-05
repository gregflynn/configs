import click

from .installer import Installer
from .modules import Modules


@click.command()
@click.option('-m', '--module')
def main(module):
    modules = Modules.get_modules()
    if module:
        modules = [m for m in modules if m.name == module]

    installer = Installer(modules)
    installer.install()


if __name__ == '__main__':
    main()
