from _src.initializer import BaseInitializer


TEST_INJECT_MAP = {
    'DS_BACKGROUND': '2D2A2E',
    'DS_BLACK': '727072',
    'DS_GRAY': '939293',
    'DS_WHITE': 'FCFCFA',

    'DS_BLUE': '78DCE8',
    'DS_GREEN': 'A9DC76',
    'DS_ORANGE': 'FC9867',
    'DS_PURPLE': 'AB9DF2',
    'DS_RED': 'FF6188',
    'DS_YELLOW': 'FFD866'
}


class Initializer(BaseInitializer):
    @property
    def requirements(self):
        return ['linux']

    def build(self):
        self.inject('index.html')
        self.inject(
            'index.html', dest='test_index.html', inject_map=TEST_INJECT_MAP
        )


def initializer():
    return Initializer
