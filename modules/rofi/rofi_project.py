import os
import json
from subprocess import check_output, run


PROJECT_DB_LOCATION = os.path.join(os.getenv('HOME'), '.rofiprojects')
ADD_PROJECT_PREFIX = '+'


def pycharm(suffix):
    install_root = os.path.join(
        os.getenv('HOME'),
        '.local/share/JetBrains/Toolbox/apps/PyCharm-P/ch-0'
    )
    version = check_output(
        'ls {} | grep -v plugins | grep -v vmoptions | tail -n 1'.format(
            install_root
        ), shell=True
    ).decode('utf8').strip() or ''
    run(
        '{}/{}/bin/pycharm.sh {}'.format(install_root, version, suffix),
        shell=True
    )


COMMAND_HANDLERS = {
    'charm': pycharm,
    'pycharm': pycharm
}
ROFI_OPTIONS = [
    'rofi', '-dmenu',
    '-matching', 'fuzzy',
]


def rofi(prompt, options, message):
    options = b'\n'.join(k.encode() for k in options)
    return check_output(
        ROFI_OPTIONS + ['-p', prompt, '-mesg', message],
        input=options
    ).decode('utf8').strip() or ''


def main():
    db = load_projects()
    command = None
    rofi_output = rofi('project', db.keys(), 'Add: +name;command')

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
        if command_head in COMMAND_HANDLERS:
            COMMAND_HANDLERS[command_head](suffix)
        else:
            run(command, shell=True)


def load_projects():
    if not os.path.isfile(PROJECT_DB_LOCATION):
        return {}

    with open(PROJECT_DB_LOCATION, 'r') as f:
        return json.loads(f.read())


def save_projects(db):
    with open(PROJECT_DB_LOCATION, 'w') as f:
        f.write(json.dumps(db))


if __name__ == '__main__':
    main()
