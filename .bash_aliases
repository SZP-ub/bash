# 启用 grep 等命令的彩色输出
if [ -x /usr/bin/dircolors ]; then
    if [ -r ~/.dircolors ]; then
        eval "$(dircolors -b ~/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# ls 和 tree 命令用 exa/eza（假定 exa/eza 已安装）
alias ls='exa --icons'
alias ll='exa -l --icons'
alias la='exa -a --icons'
alias lh='exa -lh --icons'
alias tree='eza --tree --icons'

# 翻译命令（需 fanyi 安装）
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

# pandoc 快捷键
alias pandocpdf='pandoc --pdf-engine=xelatex -V mainfont="Maple Mono NF Medium Italic" -V monofont="Maple Mono NF Medium Italic" -V CJKmainfont="Maple Mono NF CN Medium" -V CJKmonofont="Maple Mono NF CN Medium"'

# batcat 增强
alias cat='batcat --style=numbers'

# core 文件生成
coredump() {
    ulimit -c unlimited
    sudo sysctl -w kernel.core_pattern='%e.core'
    echo "core文件生成已开启"
}

# gcc 编译
alias gcc='gcc -fsanitize=address -std=c17'
alias gtest='gcc -fsanitize=address -std=c17 /home/i/tools/Unity/src/unity.c'

# cdecl 解释说明变量定义
alias cdecl='cdecl explain'
