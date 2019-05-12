from argparse import ArgumentParser

from .installer import Installer
from .modules import Modules


parser = ArgumentParser()
parser.add_argument(
    '--module',
    help='Module name to install or update',
    required=False
)


def main():
    args = parser.parse_args()

    modules = Modules.get_modules()
    if args.module:
        modules = [m for m in modules if m.name == args.module]

    installer = Installer(modules)
    installer.install()


main()
