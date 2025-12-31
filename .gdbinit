# ~/.gdbinit - 全量示例配置（已包含 pretty-printer 注册、常用快捷命令与显示选项）
# 说明：
# 1) 请根据你的系统把 libstdcxx_parent 与 eigen_printers_path 两个路径替换为实际路径（下方已给默认示例）。
# 2) 如果你把 Eigen 的 printers 放到其它位置，请修改 eigen_printers_path 或注释/取消注释相应部分。
# 3) 本文件会尝试注册 libstdc++ 的 pretty-printers（来自 /usr/share/gcc/python），并在 ~/.gdb/python/eigen 存在时注册 Eigen 的 printers。

# -------------------------
# 先执行用户指定的 Python 脚本（如果需要）
python
# 执行指定路径下的 Python 脚本（如果文件不存在会抛出异常）
try:
    exec(open("/home/i/.gdbinit.py").read())
except Exception as e:
    print("warning: failed to exec /home/i/.gdbinit.py:", e)
end

# -------------------------
# 自动注册 libstdc++ / Eigen pretty-printers（Python 块）
python
import sys, os

# ====== libstdc++ pretty-printers ======
# 将下面路径改成你系统上包含 libstdcxx 的父目录（不要指向 printers.py 文件本身）
# 你之前检查到的示例路径是：/usr/share/gcc/python
libstdcxx_parent = '/usr/share/gcc/python'
if os.path.isdir(libstdcxx_parent):
    if libstdcxx_parent not in sys.path:
        sys.path.insert(0, libstdcxx_parent)
    try:
        from libstdcxx.v6.printers import register_libstdcxx_printers
        register_libstdcxx_printers(None)
        print('libstdcxx pretty-printers registered from', libstdcxx_parent)
    except Exception as e:
        print('Failed to register libstdcxx pretty-printers:', e)
else:
    print('libstdcxx parent path not found:', libstdcxx_parent)

# ====== Eigen pretty-printers (可选) ======
# 建议把 Eigen gdb 脚本放到 ~/.gdb/python/eigen 或 /path/to/eigen/misc/gdb
eigen_printers_path = os.path.expanduser('~/.gdb/python/eigen')
if os.path.isdir(eigen_printers_path):
    if eigen_printers_path not in sys.path:
        sys.path.insert(0, eigen_printers_path)
    try:
        # 常见的导出函数名为 register_eigen_printers（不同脚本可能命名略有差异）
        from printers import register_eigen_printers
        register_eigen_printers(None)
        print('Eigen pretty-printers registered from', eigen_printers_path)
    except Exception as e:
        print('Failed to register Eigen pretty-printers:', e)
else:
    # 不存在时仅打印提示，不报错
    print('Eigen printers path not found (skipped):', eigen_printers_path)

end

# 建议把 auto-load 的安全路径包含 printers 所在目录，避免 gdb 因安全策略拒绝加载
# 如果你有其他需要允许的路径，可以用冒号 : 分隔追加
# 注意：set auto-load safe-path 在不同 gdb 版本的行为略有差异
set auto-load safe-path /usr/share/gcc/python:~/.gdb/python

# -------------------------
# 你原有的自定义命令与设置
# 定义 ll 命令，调用 highlightlist
define ll
    highlightlist
end

# 定义 xw / xg 等内存显示命令（请注意 $arg0 在使用时需要正确传参）
define xw
    x/12wx $arg0
end

define xg
    x/12gx $arg0
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
set prompt \033[1;36m   \033[0m 

# 启用日志记录，日志文件为 gdb.log，覆盖写入
set logging enabled on
set logging file gdb.log
set logging overwrite on
set logging redirect on

# 设置反汇编风格为 Intel
set disassembly-flavor intel

# 设置打印格式为美观模式（如果已注册 pretty-printers，将使用它们）
set print pretty on

# 显示容器全部元素（0 表示不限制；如容器巨大会导致大量输出）
set print elements 0

# 关闭分页，方便脚本/输出日志查看
set pagination off

# 启用 debuginfod 自动下载调试信息（需要网络）
set debuginfod enabled on

# 可选：加载 gdb-dashboard（如果你安装了且想启用）
# source ~/tools/gdb-dashboard/.gdbinit

# -------------------------
# 可选：自动加载 ~/.gdbinit.d 中的 .gdb 文件（模块化配置）
python
import glob, os, gdb
d = os.path.expanduser('~/.gdbinit.d')
if os.path.isdir(d):
    for f in sorted(glob.glob(os.path.join(d, '*.gdb'))):
        try:
            # 使用 gdb.execute('source file') 以便在 gdb 环境中加载
            gdb.execute('source ' + f)
        except Exception as e:
            print('failed to source', f, e)
end

# -------------------------
# 结束
# 提示：若想调试 printers 注册问题，可临时在 gdb 启动时添加 -ex "python ... print(...)" 来输出更多信息，
# 或在本文件中把 print(...) 改为更详细的异常回溯。
