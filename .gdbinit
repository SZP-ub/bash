python
exec(open("/home/i/.gdbinit.py").read())
end

set prompt \033[1;36m   \033[0m 

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

define ll
    highlightlist
end

# source ~/tools/gdb-dashboard/.gdbinit
