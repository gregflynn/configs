from pathlib import Path
from subprocess import check_call

import click


@click.group()
def dock():
    """Wrapper for common docker/compose commands
    """


@dock.command()
@click.argument('container_name')
def bash(container_name):
    """Create a new bash shell on a running docker container
    """
    _docker_compose('exec', container_name, 'bash')


@dock.command()
@click.argument('services', nargs=-1)
def bg(services):
    """Start one or more services in the background
    """
    _docker_compose('up', '-d', *services)


@dock.command()
@click.argument('services', nargs=-1)
def build(services):
    """Build one or more services
    """
    _docker_compose('up', '--build', *services)


@dock.command()
@click.argument('services', nargs=-1)
def down(services):
    """Bring down one or more services
    """
    if len(services) > 0:
        _docker_compose('stop', *services)
    else:
        _docker_compose('down')


@dock.command()
def edit():
    """Edit the current docker compose yaml file
    """
    yamls = sorted(Path().glob('docker-compose.y*'))
    if len(yamls) > 0:
        click.edit(filename=yamls[0].name)
    else:
        click.secho('No docker-compose yaml found.', fg='yellow')


@dock.command()
def ps():
    """List out the running containers
    """
    _docker_compose('ps')


@dock.command()
@click.argument('target',
                type=click.Choice(['all', 'containers', 'images', 'volumes']))
def purge(target):
    """Purge docker cached files
    """
    is_all = target == 'all'

    if target == 'containers' or is_all:
        check_call(['docker stop $(docker ps -a -q) > /dev/null 2>&1'],
                   shell=True)
        check_call(['docker rm $(docker ps -a -f status=exited -q)'],
                   shell=True)

    if target == 'images' or is_all:
        check_call(['docker rmi $(docker images -a -q)'], shell=True)

    if target == 'volumes' or is_all:
        check_call([
            'docker volume rm $(docker volume ls -f dangling=true -q)'],
            shell=True)


@dock.command()
@click.argument('services', nargs=-1)
def restart(services):
    """Restart one or more services
    """
    _docker_compose('restart', *services)


@dock.command()
@click.argument('container_name')
@click.argument('command', nargs=-1)
def run(container_name, command):
    """Run a command on the given running container
    """
    _docker_compose('run', container_name, *command)


@dock.command()
@click.argument('services', nargs=-1)
def up(services):
    """Start one or more services in the foreground
    """
    _docker_compose('up', *services)


def _docker_compose(*args):
    check_call(['docker-compose', *args])


if __name__ == '__main__':
    dock(prog_name='dock')
