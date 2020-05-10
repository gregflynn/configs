zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle :compinstall filename '{HOME}/.zshrc'

autoload -Uz compinit && compinit
autoload -Uz colors && colors

# history
HISTFILE=~/.histfile
HISTSIZE=50000
SAVEHIST=10000
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt inc_append_history     # add commands to HISTFILE in order of execution
setopt share_history          # share command history data

bindkey -e
export PATH=/usr/local/bin:$PATH

source '{ANTIGEN_INSTALL}'
antigen bundle zsh-users/zsh-syntax-highlighting
antigen apply

# completions
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' list-colors ''
unsetopt menu_complete
unsetopt flowcontrol
setopt auto_menu
setopt complete_in_word
setopt always_to_end

# FZF setup
export FZF_DEFAULT_OPTS='
    --color 16,fg:-1,bg:-1,hl:4,fg+:3,bg+:-1,hl+:4
    --color info:5,prompt:3,pointer:3,marker:1,spinner:2,header:1
'

source /usr/share/fzf/completion.zsh
source /usr/share/fzf/key-bindings.zsh

# fix home and end keys
bindkey '\e[1~' beginning-of-line
bindkey '\e[4~' end-of-line

# fix forward/backward word
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# fix delete key
bindkey "^[[3~" delete-char

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
setopt prompt_subst
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
		PATH="$HOME/.bin:$PATH" \
			man "$@"
}
