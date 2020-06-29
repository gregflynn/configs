from subprocess import check_output


def get_output(*args, shell=False) -> str:
    """Get the output from the given call

    Args:
        *args: shell command and arguments
        shell: set to true for pipes

    Returns:
        stdout from the given command
    """
    return check_output([*args], shell=shell).decode('utf-8')


def awk(s: str, n: int, d: str = ' ') -> str:
    """Act like awk and select the nth element

    Args:
        s: string to split up
        n: the element to select
        d: the delimiter between elements

    Returns:

    """
    split = s.strip().split(d)
    if len(split) >= n:
        # awk is 1-indexed
        return split[n - 1]
    return ''
