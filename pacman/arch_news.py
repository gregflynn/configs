import re
import sys
from xml.dom import minidom

LINK_REGEX = re.compile(r'<a.href="(?P<link>[^"]+)">(?P<name>[^<]*)</a>')
BR_REGEX = re.compile(r'<br[\s]*/>')
TAG_REGEX = re.compile(r'<[/]?[a-z]+>')
SHOWN_POSTS = 3
DESCRIPTION_REPLACEMENTS = {
    '<code>': '\033[33m',
    '</code>': '\033[0m',
    '&amp;': '&',
    '&gt;': '>',
    '&lt;': '<',
    '<p>': '\n',
}


class NewsItem(object):
    def __init__(self, element):
        self._element = element

        for attr in element.childNodes:
            data = attr.firstChild.data

            if attr.nodeName == 'title':
                self.title = data

            elif attr.nodeName == 'link':
                self.link = data

            elif attr.nodeName == 'description':
                self._original_description = data
                self.description = self._parse_description(data)

            elif attr.nodeName == 'pubDate':
                self.date = data

    @staticmethod
    def _parse_description(data):
        for key, value in DESCRIPTION_REPLACEMENTS.items():
            data = data.replace(key, value)

        data = re.sub(LINK_REGEX, r'\033[34m\g<name>\033[0m', data)
        data = re.sub(BR_REGEX, '', data)
        data = re.sub(TAG_REGEX, '', data)
        return data

    def __repr__(self):
        return f"""


\033[33m{self.title}\033[0m
\033[34m{self.date}\033[0m
\033[32m{self.link}\033[0m
{self.description}"""


if __name__ == '__main__':
    news_feed = minidom.parseString(sys.stdin.read().encode('utf-8'))

    items = news_feed.getElementsByTagName('item')

    for item in reversed(items[:SHOWN_POSTS]):
        print(NewsItem(item))
