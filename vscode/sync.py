from subprocess import call, check_output


DOTSAN_EXTENSIONS = 'extensions'


class VisualStudioCodeConnector:
    @classmethod
    def list_extensions(cls):
        output = check_output(['code', '--list-extensions']).decode('utf-8')
        return {ext for ext in output.split('\n') if ext}

    @classmethod
    def install_extension(cls, extension):
        call(['code', '--install-extenion', extension])

    @classmethod
    def uninstall_extension(cls, extension):
        call(['code', '--uninstall-extenion', extension])


def get_dotsanity_extensions():
    extensions = set()
    with open(DOTSAN_EXTENSIONS, 'r') as f:
        for extension in f.readlines():
            extensions.add(extension.strip())
    return extensions


def sync():
    dotsanity = get_dotsanity_extensions()
    installed = VisualStudioCodeConnector.list_extensions()

    # extensions to remove
    for del_extension in installed - dotsanity:
        VisualStudioCodeConnector.uninstall_extension(del_extension)

    # extensions to install
    for ins_extension in dotsanity - installed:
        VisualStudioCodeConnector.install_extension(ins_extension)


if __name__ == '__main__':
    sync()
