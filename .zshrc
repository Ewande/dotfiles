# zplug
export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

# enable conda commands
source /anaconda3/etc/profile.d/conda.sh

################################################################################
## Autocompletion
# - general
zstyle ':completion:*' group-name ''  # group autocompletion options into sections
zstyle ':completion:*:descriptions' format '%B%d%b'  # show section names (in bold)
zstyle ':completion:*' menu select  # highlight selected autocompletion
zstyle ':completion:*' special-dirs true  # add . and .. to autocompletion options
zstyle ':completion:*' list-colors ''  # colors in autocompletion
zstyle ':completion::complete:*' use-cache 1
bindkey '^[[Z' reverse-menu-complete  # shift+tab for reverse completion
# zstyle ':completion:*:warnings' format 'No matches: %d'
# zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|[._-]=* r:|=*'

# - git & docker
zplug "plugins/docker", from:oh-my-zsh
zplug "plugins/git", from:oh-my-zsh

# - make [TODO: fix, not working]
zstyle ':completion:*:make:*:targets' call-command true
zstyle ':completion:*:make::' tag-order targets

# conda autocompletion
zplug "esc/conda-zsh-completion", use:_conda

# up/down arrow command completion based on command history
zplug "zsh-users/zsh-history-substring-search"
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

################################################################################
## Prompt / Coloring / Navigation

# command prompt theme
zplug "denysdovhan/spaceship-prompt", use:spaceship.zsh, as:theme

# set the right prompt to display time
export RPROMPT="[%D{%b %f | %H:%M:%S}]"

# coloring for functions like ping
zplug "unixorn/warhol.plugin.zsh", use:warhol.plugin.zsh

# nice syntax coloring, defer:2 = load at the end
zplug "zsh-users/zsh-syntax-highlighting", defer:2

# treat only alphanumerics as words
# as a result: jumping between words will stop by e.g. `-`
autoload -U select-word-style
select-word-style bash

################################################################################

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Then, source plugins and add commands to $PATH
zplug load --verbose

export SAVEHIST=10000
export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTFILE=~/.zhistory
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt INC_APPEND_HISTORY_TIME

export PATH="/usr/local/bin:$PATH"

source ~/.secrets  # load secrets
source /usr/local/etc/grc.bashrc  # load aliases for commands with colored output


# aliases
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ls="ls -G"
alias ll="ls -lah"

################################################################################

# easy math expressions in shell using python, e.g. "= 2 * (3 + 4)"
= () { python -c "print($*)"}
aliases[=]='noglob ='

# auto import of certain packages when running INTERACTIVE python from shell
python () {
  # if not interactive, don't do anything extra
	if [ "$#" -ne 0 ]; then
		command python $@
	else
    if [ -z `command -v ipython` ]; then
      # if `ipython` is not available, use regular interpreter with a startup script
      PYTHONSTARTUP="$HOME/.ipython/profile_default/startup/00-packages.py" command python
    else
      # if `ipython` is available, use it; PYTHONSTARTUP won't work here but
      # it is not needed, as the file above will be automatically sourced by ipython
      ipython
    fi
	fi
}

# smart alias to change environments with conda
to () {
  if [ -z "$1" ]; then
    echo 'usage: to CONDA_ENV\n'
    echo 'Smart alias for `conda activate` and `conda deactivate`:'
    echo '  `to -` - deactivate current conda environment'
    echo '  `to CONDA_ENV` - activate selected conda environment'
	elif [ "$1" = '-' ]; then
		conda deactivate
	else
    if [ -n "$CONDA_PREFIX" ]; then
        conda deactivate
    fi
		conda activate $@
	fi
}

# fast completion for `to` command
__conda_envs_fast () {
	local envs=($( echo base && ls -1 ${${CONDA_EXE}%bin/conda}/envs && echo))
  if [ -n "$CONDA_PREFIX" ]; then
    # `-` to deactivate
    _describe -t go_back 'deactivate' '-'
  fi
	_describe -t envs 'conda environments' envs
}

compdef __conda_envs_fast to


clear
