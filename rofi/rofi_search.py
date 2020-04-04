from subprocess import check_output, run
from urllib.parse import quote_plus


DEFAULT_ENGINE = 'duckduckgo'
ENGINE_MAP = {
    'g': '+google',
    'google': 'https://www.google.com/search?q={}',
    'ddg': '+duckduckgo',
    'duckduckgo': 'https://duckduckgo.com/?q={}',
    'giphy': 'https://giphy.com/search/?q={}',
    'gif': '+giphy',
    'w': 'https://en.wikipedia.org/w/index.php?search={}',
    'aw': 'https://wiki.archlinux.org/index.php?search={}'
}


def main():
    options = b'\n'.join(k.encode() for k in ENGINE_MAP.keys())
    rofi_output = check_output(
        ['rofi', '-dmenu', '-p', 'search'],
        input=options
    ).decode('utf8').strip() or ''

    if not rofi_output:
        return

    url = get_url(rofi_output)

    run(['xdg-open', url])


def get_url(line):
    split_line = line.split()
    engine = split_line[0]
    whole_line_query = False

    if engine not in ENGINE_MAP:
        whole_line_query = True
        engine = DEFAULT_ENGINE

    engine_url = ENGINE_MAP[engine]
    if engine_url.startswith('+'):
        engine = engine_url[1:]
        engine_url = ENGINE_MAP[engine]

    query = line
    if not whole_line_query:
        query = ' '.join(split_line[1:])

    return engine_url.format(quote_plus(query))


if __name__ == '__main__':
    main()
