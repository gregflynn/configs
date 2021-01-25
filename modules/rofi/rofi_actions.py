import os
import json
import sys
from pathlib import Path
from argparse import ArgumentParser
from subprocess import check_call, check_output, CalledProcessError, run
from urllib.parse import quote_plus


HOME = os.getenv('HOME')
ROFI_OPTIONS = [
    'rofi', '-dmenu', '-i', '-matching', 'fuzzy',
]
ROFI_PATH = os.path.dirname(sys.argv[0])
DISPLAY_LAYOUTS_FOLDER = Path(HOME) / '.screenlayout'

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
ENGINE_ICONS = {
    'giphy': 'image-x-generic',
    'gif': 'image-x-generic',
    'w': 'accessories-dictionary',
    'aw': 'accessories-dictionary',
}

PROJECT_DB_LOCATION = os.path.join(HOME, '.rofiprojects')
ADD_PROJECT_PREFIX = '+'
PROJECT_COMMAND_ALIASES = {
    'charm': os.path.join(HOME, '.bin', 'pycharm'),
    'pycharm': os.path.join(HOME, '.bin', 'pycharm'),
    'idea': os.path.join(HOME, '.bin', 'idea')
}
PROJECT_ICONS = {
    'code': '/usr/share/icons/visual-studio-code.png',
    'charm': os.path.join(HOME, '.local/share/JetBrains/Toolbox/apps/PyCharm-P/ch-0/.icon.svg'),
    'pycharm': os.path.join(HOME, '.local/share/JetBrains/Toolbox/apps/PyCharm-P/ch-0/.icon.svg'),
    'idea': os.path.join(HOME, '.local/share/JetBrains/Toolbox/apps/IDEA-U/ch-0/.icon.svg')
}


def encode_rofi_option(option):
    if isinstance(option, str):
        return option.encode()
    else:
        # assume its a tuple with an icon
        icon, text = option
        return f'{text}\0icon\x1f{icon}'.encode()


def rofi(prompt, options, message=None):
    message_options = ['-mesg', message] if message else []
    return check_output(
        ROFI_OPTIONS + ['-p', prompt] + message_options,
        input=b'\n'.join(encode_rofi_option(o) for o in options if o)
    ).decode('utf8').strip() or ''


def actions():
    action_map = {
        'Bluetooth': lambda: check_call(['blueberry']),
        'Displays': lambda: check_call(['arandr']),
        'Home': lambda: check_call(['xdg-open', HOME]),
        'Reboot': lambda: check_call(['reboot']),
        'Sleep': lambda: check_call(['systemctl', 'suspend']),
        'Shutdown': lambda: check_call(['shutdown', '-h', 'now']),
        'Volume': lambda: check_call(['pavucontrol']),
        'VPN': lambda: check_call(
            ['bash', os.path.join(ROFI_PATH, 'rofi_vpn.sh')]),
        'Wifi': lambda: check_call(
            ['python3', os.path.join(ROFI_PATH, 'rofi_network.py')]),
        'Weather': lambda: check_call([
            'xdg-open', 'https://darksky.net/forecast/42.3501,-71.0591/us12/en'
        ]),
    }

    output = rofi(
        'system',
        [
            ('bluetooth', 'Bluetooth'),
            ('video-display', 'Displays'),
            (('accessories-screenshot', 'Display Layouts')
             if DISPLAY_LAYOUTS_FOLDER.is_dir() else False),
            ('user-home', 'Home'),
            ('icon-computer-restart', 'Reboot'),
            ('system-shutdown', 'Shutdown'),
            ('gpm-suspend', 'Sleep'),
            ('audio-card', 'Volume'),
            ('network-vpn', 'VPN'),
            ('network-wireless', 'Wifi'),
            ('weather-clear', 'Weather'),
        ]
    )

    if not output:
        return

    action_map[output]()


def calc():
    check_call([
        'rofi',
        '-show', 'calc',
        '-modi', 'calc',
        '-no-show-match',
        '-no-sort',
        '-no-history',
        '-theme-str', 'mainbox {children:[inputbar, message];}',
        '-theme-str', 'configuration {font: "Ubuntu Mono 18";}',
    ])


def display_layouts():
    if DISPLAY_LAYOUTS_FOLDER.is_dir():
        names = DISPLAY_LAYOUTS_FOLDER.glob('*.sh')

        output = rofi('display layout', sorted(names))

        check_call(['bash', DISPLAY_LAYOUTS_FOLDER / output])


def emoji():
    check_call([
        'rofimoji',
        '--rofi-args', '-theme-str "configuration {show-icons: false;}" -columns 2 -width 910',
    ])


def project():
    db = load_projects()
    options = []
    command = None

    for name in sorted(db.keys()):
        command_head, _ = db[name].split(' ', maxsplit=1)
        options.append((PROJECT_ICONS[command_head], name)
                       if command_head in PROJECT_ICONS
                       else name)

    rofi_output = rofi('project', options, 'Add: +name;command')

    if not rofi_output:
        return

    if rofi_output.startswith(ADD_PROJECT_PREFIX):
        rofi_output = rofi_output.replace(ADD_PROJECT_PREFIX, '')
        keyword, command = rofi_output.split(';', maxsplit=1)
        db[keyword] = command
        save_projects(db)
    elif rofi_output in db:
        command = db[rofi_output]

    if command:
        command_head, suffix = command.split(' ', maxsplit=1)
        if command_head in PROJECT_COMMAND_ALIASES:
            command_head = PROJECT_COMMAND_ALIASES[command_head]
        run(f'{command_head} {suffix}', shell=True)


def load_projects():
    if not os.path.isfile(PROJECT_DB_LOCATION):
        return {}

    with open(PROJECT_DB_LOCATION, 'r') as f:
        return json.loads(f.read())


def save_projects(db):
    with open(PROJECT_DB_LOCATION, 'w') as f:
        f.write(json.dumps(db))


def search():
    options = [
        (ENGINE_ICONS[e], e) if e in ENGINE_ICONS else ('system-search', e)
        for e in ENGINE_MAP.keys()
    ]
    output = rofi('search', options,
                  'Choose a prefix followed by a search term')

    if not output:
        return

    url = _get_url(output)

    check_call(['xdg-open', url])


def _get_url(line):
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


FUNC_MAP = {
    'actions': actions,
    'calc': calc,
    'display': display_layouts,
    'emoji': emoji,
    'project': project,
    'search': search,
}

if __name__ == '__main__':
    parser = ArgumentParser()
    parser.add_argument('func')

    args = parser.parse_args()
    if not args.func:
        print('func required')
        sys.exit(1)

    if args.func not in FUNC_MAP.keys():
        print('unknown func')
        sys.exit(1)

    try:
        FUNC_MAP[args.func]()
    except CalledProcessError:
        pass
