import click


class LogLevel(object):
    ERROR = 'ER'
    WARN = 'WN'
    OK = 'OK'


class Logger(object):
    LEVEL_COLORS = {
        LogLevel.ERROR: 'red',
        LogLevel.WARN: 'yellow',
        LogLevel.OK: 'green',
    }

    def __init__(self, module_name):
        self._module_name = module_name

    def log(self, level, message=''):
        click.secho(self._format_message(level, message))

    def warn(self, message):
        self.log(LogLevel.WARN, message)

    def error(self, message):
        self.log(LogLevel.ERROR, message)

    def prompt(self, message):
        while True:
            response = input(
                self._format_message(LogLevel.WARN, message + ' [Y/N] ')
            )
            if response in {'Y', 'y'}:
                return True
            if response in {'N', 'n'}:
                return False

    def _format_message(self, level, message):
        level_color = self.LEVEL_COLORS[level]
        return '{} {} {}'.format(
            click.style('[{}]'.format(level), fg=level_color),
            click.style(self._module_name, fg='blue'),
            click.style(message, fg=level_color)
        )
