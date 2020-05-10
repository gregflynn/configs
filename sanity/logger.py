class LogLevel(object):
    ERROR = 'ER'
    WARN = 'WN'
    OK = 'OK'


class TextColor(object):
    BLACK = '30'
    RED = '31'
    GREEN = '32'
    YELLOW = '33'
    BLUE = '34'
    PURPLE = '35'
    ORANGE = '36'
    WHITE = '37'


class Logger(object):
    LEVEL_COLORS = {
        LogLevel.ERROR: TextColor.RED,
        LogLevel.WARN: TextColor.YELLOW,
        LogLevel.OK: TextColor.GREEN
    }

    def __init__(self, module_name):
        self._module_name = module_name

    def log(self, level, message=''):
        print(self._format_message(level, message))

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

    @staticmethod
    def color(color, text):
        return '\033[{}m{}\033[0m'.format(color, text)

    def _format_message(self, level, message):
        level_color = self.LEVEL_COLORS[level]
        return '{} {} {}'.format(
            self.color(level_color, '[{}]'.format(level)),
            self.color(TextColor.BLUE, self._module_name),
            self.color(level_color, message)
        )
