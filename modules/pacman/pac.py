import os
import re
import sys
import json
from datetime import datetime
from subprocess import CalledProcessError, check_call, check_output, DEVNULL
from pathlib import Path
from xml.dom import minidom

import click
import requests
from click import secho

from sanity import settings
from sanity.util.echo import secho_line
from sanity.util.shell import get_output, awk
from sanity.package_manager import PackageManager

PACMAN_CACHE = '/var/cache/pacman/pkg'
PACMAN_LOG = '/var/log/pacman.log'
AUR_HOME = settings.home_path('.aur')
PACKAGE_WATCH_LIST = {
    'alacritty', 'awesome', 'bash', 'docker', 'feh', 'firefox', 'git',
    'gnome-keyring', 'kitty', 'libinput-gestures', 'linux', 'neovim', 'nvidia',
    'pacman', 'python', 'redshift', 'rofi', 'systemd', 'task', 'tmux', 'vim',
    'zsh'
}


@click.group()
def pac():
    """Arch Linux Pacman Wrapper
    """


#
# Core
#
@pac.command()
@click.argument('package_names', nargs=-1)
def install(package_names):
    """Install packages
    """
    if package_names:
        _pac('-S', *package_names)


@pac.command()
def update():
    """Update all the packages on the system
    """
    _pac('-Syy')
    updates = [p for p in get_output('pacman', '-Qu').split('\n')]

    if not updates:
        return

    update_details = {awk(u, 1): {'old': awk(u, 2), 'new': awk(u, 4)}
                      for u in updates}

    watched_updates = PACKAGE_WATCH_LIST.intersection(
        set(update_details.keys()))

    if watched_updates:
        secho('Watched packages updated', fg='yellow')

        for wu in watched_updates:
            secho_line((wu, 'blue'), ': ',
                       (update_details[wu]['old'], 'yellow'), ' -> ',
                       (update_details[wu]['new'], 'green'))

    _pac('-Su')


@pac.command()
@click.argument('package_names', nargs=-1)
def remove(package_names):
    """Remove packages from the system
    """
    aur_package_names = _aur_package_names()
    for p in package_names:
        _pac('-Rs', p)

        if p in aur_package_names:
            aur_path = Path(AUR_HOME) / p
            if aur_path.exists():
                aur_path.rmdir()


#
# AUR
#
@pac.group()
def aur():
    """Commands for managing Arch User Repository packages
    """


@aur.command()
@click.argument('packages', nargs=-1)
def clean(packages):
    """Clean the aur build directory for the given packages
    """
    aur_package_names = _aur_package_names()

    for pkg in packages:
        if pkg in aur_package_names:
            path = Path(AUR_HOME) / pkg
            os.chdir(str(path))
            check_call(['git', 'checkout', 'master'])
            check_call(['git', 'clean', '-fdx'])


@aur.command()
@click.argument('packages', nargs=-1)
def install(packages):
    """Install packages from the Arch User Repository
    """
    aur_package_names = _aur_package_names()

    for pkg in packages:
        if pkg in aur_package_names:
            secho(f'{pkg} is already installed.', fg='yellow')
            continue

        checkout_path = Path(AUR_HOME) / pkg

        try:
            check_call(['git', 'clone', f'https://aur.archlinux.org/{pkg}',
                        str(checkout_path)])
        except CalledProcessError:
            if checkout_path.exists():
                checkout_path.rmdir()

        if not checkout_path.exists():
            secho(f'{pkg} was not found.', fg='yellow')
            continue

        try:
            _build_aur_package(checkout_path)
        except CalledProcessError:
            secho(f'{pkg} failed to build.', fg='yellow')
            continue

        try:
            _install_built_package(checkout_path)
        except CalledProcessError:
            secho(f'{pkg} failed to build.', fg='yellow')
            continue


@aur.command()
@click.argument('packages', nargs=-1)
def update(packages):
    """Update all or some packages from the Arch User Repository
    """
    aur_packages = _aur_package_names()
    selected_packages = packages if packages else sorted(aur_packages)
    ask_confirmation = not packages
    updates = []

    for pkg in selected_packages:
        if pkg not in aur_packages:
            secho(f'{pkg} is not installed via user repository.')
            continue

        path = Path(AUR_HOME) / pkg
        _aur_git_pull(path)

        if _aur_check_update(path):
            updates.append(path)

        _aur_print_version(path)

    if not updates:
        click.echo('No updates available.')
        return

    if ask_confirmation:
        click.echo('\nThe following packages have updates available:')
        for path in updates:
            _aur_print_version(path)

        click.confirm('=> install updates?', abort=True)

    built_packages = []
    for path in updates:
        try:
            _build_aur_package(path)
            built_packages.append(path)
        except CalledProcessError:
            secho(f'{path.name} failed to build.', fg='yellow')

    for path in built_packages:
        _install_built_package(path)


def _build_aur_package(path: Path):
    os.chdir(str(path))
    check_call(['makepkg', '-sf'])


def _install_built_package(path: Path):
    os.chdir(str(path))
    latest_version = _aur_latest_version(path)
    package_path = list(path.glob(f'*{latest_version}*'))[0]
    _pac('-U', package_path, '--needed', '--noconfirm')


def _aur_latest_version(path: Path):
    def extract_version(line):
        return line.split('=', maxsplit=1)[1].strip()\
            .replace('"', '').replace("'", '')

    with (path / 'PKGBUILD').open('r') as f:
        pkgver = None
        pkgrel = None
        epoch = None

        for line in f.readlines():
            if line.startswith('pkgver='):
                pkgver = extract_version(line)
            elif line.startswith('pkgrel='):
                pkgrel = extract_version(line)
            elif line.startswith('epoch='):
                epoch = extract_version(line)

        if epoch:
            return f'{epoch}:{pkgver}-{pkgrel}'
        else:
            return f'{pkgver}-{pkgrel}'


def _aur_installed_version(path: Path):
    try:
        return awk(
            check_output(['pacman', '-Q', path.name]).decode('utf-8'), 2)
    except CalledProcessError:
        return None


def _aur_git_pull(path: Path):
    os.chdir(str(path))
    check_call(['git', 'checkout', 'master'], stdout=DEVNULL, stderr=DEVNULL)
    check_call(['git', 'pull', '-q'], stdout=DEVNULL)


def _aur_check_update(path: Path):
    installed = _aur_installed_version(path)

    if not installed:
        return False

    latest = _aur_latest_version(path)
    return latest != installed


def _aur_print_version(path: Path):
    installed = _aur_installed_version(path)

    if _aur_check_update(path):
        latest = _aur_latest_version(path)
        if not installed:
            secho_line(('[NA] ', 'red'), (path.name, 'blue'), ': ',
                       (latest, 'red'))
        else:
            secho_line(('[UP] ', 'yellow'), (path.name, 'blue'), ': ',
                       (installed, 'yellow'), ' -> ', (latest, 'green'))
    else:
        secho_line(('[OK] ', 'green'), (path.name, 'blue'), ': ',
                   (installed, 'green'))


#
# Cache
#
@pac.group()
def cache():
    """Operations on the pacman package cache on local disk
    """


@cache.command()
def info():
    """Print general information about the local pacman package cache
    """
    secho_line(('Pacman Package Cache ', 'blue'), (PACMAN_CACHE, 'green'))
    # secho('Pacman Package Cache ', fg='blue', nl=False)
    # secho(PACMAN_CACHE, fg='green')
    _pac_cache_info()


@cache.command()
@click.argument('package_name')
def show(package_name):
    """Show versions in the cache for the given package_name
    """
    current_version = awk(get_output('pacman', '-Q', package_name), 2)

    if not current_version:
        return

    pkg_regex = re.compile(f'^{package_name}-[0-9]')
    pkg_and_mod_times = []

    for pkg in Path(PACMAN_CACHE).glob(f'{package_name}*.tar.*'):
        if pkg_regex.match(pkg.name):
            modified = os.path.getmtime(str(pkg))
            pkg_and_mod_times.append((pkg, modified))

    for pamt in sorted(pkg_and_mod_times, key=lambda pamt: pamt[1]):
        pkg, modified = pamt
        secho_line(
            (datetime.fromtimestamp(modified).strftime('%F %r'), 'blue'),
            (' > ', 'yellow'),
            (pkg.name, (
               'green'
               if pkg.name.startswith(f'{package_name}-{current_version}')
               else 'white'
            ))
        )


@cache.command()
def prune():
    """Clear uninstalled and old packages from the cache
    """
    pkg_manager = PackageManager()
    if not pkg_manager.is_installed('pacman-contrib'):
        secho('pacman-contrib is not installed', fg='red')
        return

    _pac_cache_info()
    secho('Removing uninstalled packages...')
    check_call(['paccache', '-r', '-c', PACMAN_CACHE, '-u'])

    secho('Removing old packages...')
    check_call(['paccache', '-r', '-c', PACMAN_CACHE, '-k', '10'])
    _pac_cache_info()


@cache.command()
@click.argument('package_name')
@click.argument('version')
def revert(package_name, version):
    """Revert a package version to one stored in the cache
    """
    tar_path = f'{PACMAN_CACHE}/{package_name}-{version}-x86_64.pkg.tar'

    if os.path.isfile(tar_path + '.zst'):
        pkg_path = tar_path + '.zst'
    elif os.path.isfile(tar_path + '.xz'):
        pkg_path = tar_path + '.xz'
    else:
        secho(f'Version not found in cache: {version}', fg='red')
        return
    _pac('-U', pkg_path)


def _pac_cache_info():
    num_packages = len(os.listdir(PACMAN_CACHE))
    cache_size = awk(get_output('du', '-h', '-d', '1', PACMAN_CACHE),
                     1, d='\t')
    secho_line((str(num_packages), 'green'), (' Cached Packages', 'blue'))
    secho_line((cache_size.strip(), 'green'), (' on disk', 'blue'))


#
# Query
#
@pac.command(name='list')
@click.argument('mode', required=False,
                type=click.Choice(['dead', 'explicit', 'orphans', 'aur']))
@click.option('--package', '-p', help='filter by package name')
def list_(mode, package=None):
    """List installed packages on the system
    """
    if mode == 'aur':
        packages = sorted(_aur_package_names())

    elif mode == 'dead':
        aur_packages = _aur_package_names()
        dead_pkgs = _pac_query('mq')
        packages = [p for p in dead_pkgs if p not in aur_packages]

    elif mode == 'explicit':
        packages = _pac_query('en')

    elif mode == 'orphans':
        packages = _pac_query('tdq')

    else:
        packages = _pac_query('')

    for pkg in packages:
        if package is None or package.lower() in pkg.lower():
            click.echo(pkg)


@pac.command()
@click.argument('package_name')
def info(package_name):
    """Query detailed package information
    """
    check_call(['pacman', '-Qi', package_name])


#
# Search
#
@pac.command()
@click.argument('term')
@click.option('--aur/--no-aur', default=False)
def search(term, aur):
    """Search the official repositories
    """
    if aur:
        secho()
        _bar('Arch Core')
    try:
        remote = get_output('pacman', '-Ss', term)
    except CalledProcessError:
        remote = ''

    def echo_result(name, repo, version, description, installed=False):
        secho()
        secho(name, fg='yellow', nl=False)
        secho(f' ({repo}) ', fg='bright_black', nl=False)
        secho(version, nl=not installed)
        if installed:
            secho('[i]', fg='green')
        secho(description)

    if remote:
        lines = remote.split('\n')

        i = 1
        while i < len(lines):
            title_line = lines[i - 1]
            desc_line = lines[i]

            repo, parts = title_line.split('/', maxsplit=1)
            parts = parts.split(' ', maxsplit=1)
            installed = parts[1].endswith('[installed]')
            version = parts[1][:-11] if installed else parts[1]

            echo_result(parts[0], repo, version, desc_line, installed)

            i += 2

    else:
        secho('Nothing found', fg='red')

    if aur:
        secho()
        _bar('Arch User Repository')

        aur_search = json.loads(requests.get(
            f'https://aur.archlinux.org/rpc.php?v=5&type=search&arg={term}'
        ).text)

        if len(aur_search['results']):
            installed_aur_pkgs = _aur_package_names()
            for r in sorted(aur_search['results'], key=lambda x: x['Name']):
                name = r['Name']
                echo_result(name, 'aur', r['Version'], r['Description'],
                            name in installed_aur_pkgs)
        else:
            secho('Nothing found', fg='red')


@pac.command()
@click.argument('query', required=False)
@click.option('--aur/--no-aur', default=False)
def web(query, aur=False):
    """Search for packages on the Arch site
    """
    url = ('https://aur.archlinux.org/packages/'
           if aur else 'https://www.archlinux.org/packages/')

    if query:
        click.launch(f'{url}?K={query}' if aur else f'{url}?q={query}')
    else:
        click.launch(url)


@pac.command()
@click.option('-p', '--package', help='Filter history for this package only')
def history(package):
    """Show package update history
    """

    with open(PACMAN_LOG, 'r') as f:
        for line in f.readlines():
            split_line = line.split(' ')

            if len(split_line) < 4 or split_line[1] != '[ALPM]':
                continue

            if split_line[2] not in {'installed', 'upgraded', 'removed'}:
                continue

            if package and split_line[3] != package:
                continue

            secho(' '.join([split_line[0]] + split_line[2:]), nl=False)


#
# News
#
LINK_REGEX = re.compile(r'<a.href="(?P<link>[^"]+)">(?P<name>[^<]*)</a>')
BR_REGEX = re.compile(r'<br[\s]*/>')
TAG_REGEX = re.compile(r'<[/]?[a-z]+>')
SHOWN_POSTS = 3
DESCRIPTION_REPLACEMENTS = {
    '<code>': '\033[36m',
    '</code>': '\033[0m',
    '&amp;': '&',
    '&gt;': '>',
    '&lt;': '<',
    '<p>': '\n',
}


class NewsItem(object):
    def __init__(self, element):
        self._element = element

        for attr in element.childNodes:
            data = attr.firstChild.data

            if attr.nodeName == 'title':
                self.title = data

            elif attr.nodeName == 'link':
                self.link = data

            elif attr.nodeName == 'description':
                self._original_description = data
                self.description = self._parse_description(data)

            elif attr.nodeName == 'pubDate':
                self.date = data

    @staticmethod
    def _parse_description(data):
        for key, value in DESCRIPTION_REPLACEMENTS.items():
            data = data.replace(key, value)

        data = re.sub(LINK_REGEX, r'\033[34m\g<name>\033[0m', data)
        data = re.sub(BR_REGEX, '', data)
        data = re.sub(TAG_REGEX, '', data)
        return data


@pac.command()
def news():
    """Show the latest news from the Arch Linux RSS feed
    """
    raw_news = requests.get('https://www.archlinux.org/feeds/news/').text
    news_feed = minidom.parseString(raw_news)

    items = news_feed.getElementsByTagName('item')

    for item in reversed(items[:SHOWN_POSTS]):
        ni = NewsItem(item)
        secho()
        _bar()
        secho()
        secho(ni.title, fg='yellow')
        secho(ni.date, fg='blue')
        secho(ni.link, fg='green')
        secho(ni.description)


def _pac(*args):
    try:
        check_call(['sudo', 'pacman',  *args])
    except CalledProcessError:
        sys.exit(1)


def _pac_query(flags: str):
    return [awk(p, 1)
            for p in get_output('pacman', f'-Q{flags}').strip().split('\n')]


def _aur_package_names() -> set:
    """Get the names of packages installed via AUR
    """
    return {aur_path.name for aur_path in Path(AUR_HOME).iterdir()
            if aur_path.is_dir()}


def _bar(title=''):
    if len(title) > 0:
        bar = f'### {title.upper()} {"#" * (45 - len(title))}'
    else:
        bar = '#' * 50

    secho(bar, fg='bright_black')


if __name__ == '__main__':
    pac(prog_name='pac')
