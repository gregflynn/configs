# from IPython import get_ipython
from IPython.terminal.prompts import Prompts, Token


# ip = get_ipython()


class MyPrompt(Prompts):
    def in_prompt_tokens(self, cli=None):
        return [(Token.Prompt, ' ')]

    def out_prompt_tokens(self, cli=None):
        return [(Token.OutPrompt, ' ')]


## Whether to display a banner upon starting IPython.
c.TerminalIPythonApp.display_banner = False

## Autoformatter to reformat Terminal code. Can be `'black'` or `None`
c.TerminalInteractiveShell.autoformatter = 'black'

## Set to confirm when you try to exit IPython with an EOF (Control-D in Unix,
#  Control-Z/Enter in Windows). By typing 'exit' or 'quit', you can force a
#  direct exit without any confirmation.
c.TerminalInteractiveShell.confirm_exit = False

## Options for displaying tab completions, 'column', 'multicolumn', and
#  'readlinelike'. These options are for `prompt_toolkit`, see `prompt_toolkit`
#  documentation for more information.
c.TerminalInteractiveShell.display_completions = 'column'

# Highlight matching brackets.
c.TerminalInteractiveShell.highlight_matching_brackets = True

# The name or class of a Pygments style to use for syntax highlighting. To see
#  available styles, run `pygmentize -L styles`.
# c.TerminalInteractiveShell.highlighting_style = 'monokai'

# Override highlighting format for specific tokens
c.TerminalInteractiveShell.highlighting_style_overrides = {
    Token.String: '#{DS_YELLOW}',
    Token.String.Escape: 'bold #{DS_PURPLE}',
    Token.Prompt: '#{DS_GREEN}',
    Token.OutPrompt: '#{DS_RED}',
    Token.Comment: '#{DS_YELLOW}',
    Token.Error: '#{DS_RED}',
    Token.Escape: '#{DS_PURPLE}',
    Token.Generic: '#{DS_BLUE}',
    Token.Keyword: 'italic nobold #{DS_RED}',
    Token.Literal: '#{DS_PURPLE}',
    Token.Name: '#{DS_WHITE}',
    Token.Name.Builtin: 'italic #{DS_BLUE}',
    Token.Name.Class: '#{DS_GREEN}',
    Token.Name.Decorator: '#{DS_GREEN}',
    Token.Name.Function: '#{DS_GREEN}',
    Token.Number: '#{DS_PURPLE}',
    Token.Operator: '#{DS_RED}',
    Token.Operator.Word: 'italic nobold #{DS_RED}',
}

## Class used to generate Prompt token for prompt_toolkit
c.TerminalInteractiveShell.prompts_class = MyPrompt

## Use 24bit colors instead of 256 colors in prompt highlighting. If your
#  terminal supports true color, the following command should print 'TRUECOLOR'
#  in orange: printf "\x1b[38;2;255;100;0mTRUECOLOR\x1b[0m\n"
c.TerminalInteractiveShell.true_color = False

