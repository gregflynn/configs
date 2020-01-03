import sys
from xml.dom import minidom


SHOWN_POSTS = 3


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
                self.description = data

            elif attr.nodeName == 'pubDate':
                self.date = data

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

