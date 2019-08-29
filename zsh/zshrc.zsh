zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle :compinstall filename '{HOME}/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install
# If you come from bash you might have to change your $PATH.
export PATH=/usr/local/bin:$PATH

SHOW_AWS_PROMPT=false
export FZF_DEFAULT_OPTS='
    --color 16,fg:-1,bg:-1,hl:4,fg+:3,bg+:-1,hl+:4
    --color info:5,prompt:3,pointer:3,marker:1,spinner:2,header:1
'

. '{ANTIGEN_INSTALL}'

# oh-my-zsh packages
antigen use oh-my-zsh
#antigen bundle aws
antigen bundle fzf
antigen bundle git

# github packages
antigen bundle zsh-users/zsh-syntax-highlighting

antigen apply

# fix home and end keys
bindkey '\e[1~' beginning-of-line
bindkey '\e[4~' end-of-line

alias compreinit='rm -f ~/.zcompdump; compinit'

{DS_SOURCE}
__ds__src "{DS_SOURCES}"
fpath=({DS_COMP_ZSH} $fpath)

# ZSH Syntax Highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
ZSH_HIGHLIGHT_STYLES[command]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[alias]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[function]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[path]='fg=magenta'

# Theme
. '{ZSH_PROMPT}'

# fork colored man pages to fix some terrible colors
# from: https://github.com/robbyrussell/oh-my-zsh/blob/master/plugins/colored-man-pages/colored-man-pages.plugin.zsh
man() {
	env \
		LESS_TERMCAP_mb=$(printf "\e[1;31m") \
		LESS_TERMCAP_md=$(printf "\e[1;31m") \
		LESS_TERMCAP_me=$(printf "\e[0m") \
		LESS_TERMCAP_se=$(printf "\e[0m") \
		LESS_TERMCAP_so=$(printf "\e[0;43;30m") \
		LESS_TERMCAP_ue=$(printf "\e[0m") \
		LESS_TERMCAP_us=$(printf "\e[1;32m") \
		PAGER="${commands[less]:-$PAGER}" \
		_NROFF_U=1 \
		PATH="$HOME/bin:$PATH" \
			man "$@"
}
