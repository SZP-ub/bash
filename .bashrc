# ~/.bashrc: executed by bash(1) for non-login shells.
# 参考 /usr/share/doc/bash/examples/startup-files（bash-doc 包）

# 如果不是交互式 shell，则直接返回
case $- in
    *i*) ;;
      *) return;;
esac

# =======================
# 历史记录相关设置
# =======================

# 不记录重复命令或以空格开头的命令
HISTCONTROL=ignoreboth

# 追加历史记录而不是覆盖
shopt -s histappend

# 历史记录条数
HISTSIZE=1000
HISTFILESIZE=2000

# 每次命令后自动检查窗口大小，必要时更新 LINES 和 COLUMNS
shopt -s checkwinsize

# 如果设置，globstar 可让 ** 匹配多级目录（默认注释）
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
    xterm-color|*-256color) color_prompt=yes;;
esac

# 如需强制彩色提示符，取消下一行注释
#force_color_prompt=yes

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

# 如果是 xterm，设置窗口标题
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# =======================
# 常用命令别名
# =======================

# 启用 ls/grep 等命令的彩色输出
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# GCC 彩色警告和错误（如需启用取消注释）
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# 更友好的 ls 和 tree 命令（需 exa/eza 安装）
alias ls='exa --icons'           # 彩色图标 ls
alias ll='exa -l --icons'        # 长列表
alias la='exa -a --icons'        # 显示所有文件
alias lh='exa -lh --icons'       # 人类可读大小
alias tree='eza --tree --icons'  # 目录树
alias cat='cat -n'               # 显示行号
alias ff='fanyi'                 # 快速翻译

# 长时间命令结束后桌面通知
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# 建议将自定义别名放到 ~/.bash_aliases 文件中
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
# 编辑器别名
# =======================
alias vim='nvim'         # 用 nvim 替代 vim
alias vimm='nvim -M'     # 只读模式

# 美化 git log（如需启用取消注释）
alias glg='git log --pretty=format:"%C(auto)提交：%h %d%n作者：%an%n日期：%ar（%ad）%n说明：%s%n" --date="format:%Y-%m-%d"'

# 美化 yadm log（如需启用取消注释）
alias ylg='yadm log --pretty=format:"%C(auto)提交：%h %d%n作者：%an%n日期：%ar（%ad）%n说明：%s%n" --date="format:%Y-%m-%d"'

# =======================
# pandoc *.md -o *.pdf
# =======================
alias pandocpdf='pandoc --pdf-engine=xelatex -V mainfont="Maple Mono NF Medium Italic" -V monofont="Maple Mono NF Medium Italic" -V CJKmainfont="Maple Mono NF CN Medium" -V CJKmonofont="Maple Mono NF CN Medium"'

# =======================
# PATH 和环境变量
# =======================

# pipx 安装的可执行文件路径
export PATH="$PATH:/home/i/.local/bin"

# nvm（Node 版本管理器）环境变量
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # 加载 nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # 加载 nvm 补全

# 输入法环境变量（fcitx）
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"

# =======================
# 其他增强
# =======================

# 启用 starship 高级提示符
eval "$(starship init bash)"

# 启用 vi 模式（如需启用取消注释）
# set -o vi

# 启用 zoxide 替换 cd
eval "$(zoxide init --cmd cd bash)"
