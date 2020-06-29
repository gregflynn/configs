import click


def secho_line(*args):
    """Like click.secho but as a single line

    Args:
        *args: a string or a tuple of (message, fg, bg)
    """
    for arg in args:
        if isinstance(arg, (list, tuple)):
            click.secho(arg[0],
                        fg=arg[1],
                        bg=arg[2] if len(arg) > 2 else None,
                        nl=False)
        else:
            click.secho(arg, nl=False)

    click.echo()
