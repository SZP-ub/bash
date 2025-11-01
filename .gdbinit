# 加载 Python 命令
python
exec(open("/home/i/.gdbinit.py").read())  # 执行指定路径下的 Python 脚本
end

# 定义 ll 命令，调用 highlightlist
define ll
    highlightlist
end

# 定义 xx 命令，显示内存内容（8个64位十六进制数）
define xx
    x/8gx $arg0
end

# 定义 pf 命令，支持多参数格式化输出
define pf
    if $argc == 2
        printf $arg0, $arg1
    end
    if $argc == 3
        printf $arg0, $arg1, $arg2
    end
    if $argc == 4
        printf $arg0, $arg1, $arg2, $arg3
    end
    if $argc == 5
        printf $arg0, $arg1, $arg2, $arg3, $arg4
    end
end

# 定义 rr 命令，运行并开启全记录
define rr
    run
    target record-full
end

# 设置 GDB 命令行提示符为高亮的“”
set prompt \033[1;36m   \033[0m 

# 启用日志记录，日志文件为 gdb.log，覆盖写入
set logging enabled on
set logging file gdb.log
set logging overwrite on

# 设置反汇编风格为 Intel
set disassembly-flavor intel

# 设置打印格式为美观模式
set print pretty on

# 启用 debuginfod 自动下载调试信息
set debuginfod enabled on

# 加载 gdb-dashboard（可选，已注释）
# source ~/tools/gdb-dashboard/.gdbinit
