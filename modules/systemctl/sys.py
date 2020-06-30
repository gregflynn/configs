from subprocess import check_call

import click

from sanity.util.shell import get_output, awk


@click.group()
def sys():
    """Wrapper for common systemctl/journalctl commands
    """


@sys.command()
def last():
    """Show the last boot's log file
    """
    _journalctl('--boot=-1')


@sys.command(name='list')
@click.argument('filter', required=False)
def list_(filter=None):
    """List unit files
    """
    unit_lines = get_output('systemctl', 'list-unit-files', '--no-pager')\
        .split('\n')
    units = []

    for l in unit_lines:
        if 'enabled' in l or 'disabled' in l:
            if filter is None or filter in l:
                units.append(awk(l, 1))

    click.echo('\n'.join(sorted(units)))


@sys.command()
@click.argument('unit', required=False)
def log(unit=None):
    """Show the system log or a unit's log
    """
    if unit:
        _journalctl('-xeu', unit)
    else:
        _journalctl('-xe')


@sys.command()
@click.argument('unit')
def start(unit):
    """Start a systemctl unit
    """
    _systemctl('start', unit)
    status(unit)


@sys.command()
@click.argument('unit')
def status(unit):
    """Show the status of the given unit
    """
    _systemctl('--no-pager', 'status', unit)


@sys.command()
@click.argument('unit')
def stop(unit):
    """Stop a systemctl unit
    """
    _systemctl('stop', unit)


@sys.command()
@click.argument('unit')
def restart(unit):
    """Restart a systemctl unit
    """
    _systemctl('restart', unit)


@sys.command()
@click.argument('unit')
def enable(unit):
    """Enable a systemctl unit to start at boot
    """
    _systemctl('enable', unit)


@sys.command()
@click.argument('unit')
def disable(unit):
    """Disable a systemctl unit from starting at boot
    """
    _systemctl('disable', unit)


def _journalctl(*args):
    check_call(['sudo', 'journalctl', *args])


def _systemctl(*args):
    check_call(['sudo', 'systemctl', *args])


if __name__ == '__main__':
    sys(prog_name='sys')
