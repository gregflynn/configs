from setuptools import setup


setup(
    name='sanity',
    version='1.0',
    author='Greg Flynn',
    url='https://github.com/gregflynn/dotsanity',
    packages=['sanity'],
    provides=['sanity'],
    install_requires=[
        'click==7.1.2',
        'dataset==1.3.1',
        'requests==2.24.0',
        'wheel'
    ],
    entry_points='''
        [console_scripts]
        dotsan=sanity.command:dotsan
    ''',
)
