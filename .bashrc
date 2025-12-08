# ~/.bashrc: executed by bash(1) for non-login shells.

# 如果不是交互式 shell，则直接返回
case $- in
*i*) ;;
*) return ;;
esac

# =======================
# 历史记录相关设置
# =======================

HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s checkwinsize
#shopt -s globstar

# =======================
# less 管道支持
# =======================
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# =======================
# chroot 环境提示
# =======================
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# =======================
# 设置命令提示符（PS1）
# =======================
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

case "$TERM" in
xterm* | rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*) ;;
esac

# =======================
# 加载自定义别名
# =======================
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# =======================
# 补全功能
# =======================
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# =======================
# PATH 和环境变量
# =======================

export PATH="$PATH:/home/i/.local/bin"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"

export FZF_DEFAULT_OPTS='--layout=reverse --bind=tab:down,ctrl-n:toggle+down,shift-tab:up,ctrl-p:toggle+up --preview "batcat --style=numbers --color=always --line-range :500 {}"'

export PATH="$PATH:/home/i/tools/advcpmv"

# =======================
# 其他增强
# =======================

eval "$(starship init bash)"
eval "$(zoxide init --cmd cd bash)"

. "$HOME/.cargo/env"
export PATH="$HOME/.local/bin:$PATH"
source ~/tools/bashmarks/bashmarks.sh
export PATH="$HOME/tools/lua-language-server-3.16.1-linux-x64/bin:$PATH"
