# 加载 Python 命令
python
exec(open("/home/i/.gdbinit.py").read())
end

define ll
    highlightlist
end

define xx
    x/8xw $arg0
end

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

define r
    run
    target record-full
end

set prompt \033[1;36m   \033[0m 

set logging enabled on
set logging file gdb.log
set logging overwrite on


set disassembly-flavor intel

set print pretty on

# source ~/tools/gdb-dashboard/.gdbinit
