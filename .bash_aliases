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

# 更友好的 ls 和 tree 命令（需 exa/eza 安装）
alias ls='exa --icons'
alias ll='exa -l --icons'
alias la='exa -a --icons'
alias lh='exa -lh --icons'
alias tree='eza --tree --icons'
alias ff='fanyi'

# 长时间命令结束后桌面通知
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# 编辑器别名
alias vim='nvim'
alias vimm='nvim -M'

# Git 快捷键
alias glg='git --no-pager log --pretty=format:"%C(auto)提交：%h %d%n作者：%an%n日期：%ar（%ad）%n说明：%s%n" --date="format:%Y-%m-%d"'
alias gin='git init'
alias gsu='git status'
alias ga='git add'
alias gcm='git commit -m'
alias gca='git commit -a -m'
alias gp='git push'
alias gb='git branch'
alias gco='git checkout'
alias gd='git diff'
alias gpl='git pull'
alias gcl='git clone'
alias grv='git remote -v'

# yadm 快捷键
alias ylg='yadm --no-pager log --pretty=format:"%C(auto)提交：%h %d%n作者：%an%n日期：%ar（%ad）%n说明：%s%n" --date="format:%Y-%m-%d"'
alias yin='yadm init'
alias ysu='yadm status'
alias yad='yadm add'
alias ycm='yadm commit -m'
alias yca='yadm commit -a -m'
alias yp='yadm push'
alias yb='yadm branch'
alias yco='yadm checkout'
alias yd='yadm diff'
alias ypl='yadm pull'
alias ycl='yadm clone'
alias yrv='yadm remote -v'

# pandoc 快捷键
alias pandocpdf='pandoc --pdf-engine=xelatex -V mainfont="Maple Mono NF Medium Italic" -V monofont="Maple Mono NF Medium Italic" -V CJKmainfont="Maple Mono NF CN Medium" -V CJKmonofont="Maple Mono NF CN Medium"'
# alias pandocpdf='pandoc --pdf-engine=xelatex -V mainfont="Maple Mono NF Medium Italic" -V monofont="Maple Mono NF Medium Italic" -V CJKmainfont="Maple Mono NF CN Medium" -V CJKmonofont="Maple Mono NF CN Medium" -V japanesefont="Noto Sans CJK JP" -V CJKoptions=AutoFakeBold'

# batcat 增强
alias cat='batcat --style=numbers'

# fzf 文件浏览时预览内容（高亮）
# alias fzf='fzf --layout=reverse --preview "batcat --style=numbers --color=always --line-range :500 {}"'
alias fzf='fzf --layout=reverse --bind=tab:down,ctrl-n:toggle+down,shift-tab:up,ctrl-p:toggle+up --preview "batcat --style=numbers --color=always --line-range :500 {}"'

# core生成
core() {
    ulimit -c unlimited
    sudo sysctl -w kernel.core_pattern='%e.core'
    echo "core文件生成已开启"
}

# gcc 编译
alias gcc='gcc -g -std=c17'
