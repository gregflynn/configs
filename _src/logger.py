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
    CYAN = '36'
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
        level_color = self.LEVEL_COLORS[level]
        print('{} {} {}'.format(
            self.color(level_color, '[{}]'.format(level)),
            self.color(TextColor.BLUE, self._module_name),
            self.color(level_color, message)
        ))

    @staticmethod
    def color(color, text):
        return '\033[{}m{}\033[0m'.format(color, text)
