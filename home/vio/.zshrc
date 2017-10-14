autoload -Uz compinit promptinit up-line-or-beginning-search down-line-or-beginning-search run-help
compinit
promptinit

# This will set the default prompt to the walters theme
prompt lambda-pure

# autocompletion
zstyle ':completion:*' menu select

# history search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

[[ -n "$key[Up]"   ]] && bindkey -- "$key[Up]"   up-line-or-beginning-search
[[ -n "$key[Down]" ]] && bindkey -- "$key[Down]" down-line-or-beginning-search

# pkgfile "command not found"
source /usr/share/doc/pkgfile/command-not-found.zsh

# rename run-help to help
unalias run-help
alias help=run-help

