# Monokai风格颜色组
class ColorsMonokai:
    FG_DEFAULT = "\033[38;2;248;248;242m"
    FG_COMMENT = "\033[38;2;117;113;94m"
    FG_RED     = "\033[38;2;249;38;114m"
    FG_ORANGE  = "\033[38;2;253;151;31m"
    FG_YELLOW  = "\033[38;2;230;219;116m"
    FG_GREEN   = "\033[38;2;166;226;46m"
    FG_BLUE    = "\033[38;2;102;217;239m"
    FG_PURPLE  = "\033[38;2;174;129;255m"
    RESET      = "\033[0m"
    BOLD       = "\033[1m"

# 高亮列表命令
import gdb

class HighlightList(gdb.Command):
    def __init__(self):
        super(HighlightList, self).__init__("highlightlist", gdb.COMMAND_USER)
    def invoke(self, arg, from_tty):
        frame = gdb.selected_frame()
        sal = frame.find_sal()
        filename = sal.symtab.filename
        current_line = sal.line
        start = max(current_line - 5, 1)
        end = current_line + 5
        highlight_start = ColorsMonokai.FG_ORANGE
        highlight_end = ColorsMonokai.RESET
        with open(filename) as f:
            lines = f.readlines()
        for i in range(start, min(end, len(lines)+1)):
            if i == current_line:
                print(f" =>{highlight_start}{i:3d}: {lines[i-1].rstrip()}{highlight_end}")
            else:
                print(f"   {i:4d}: {lines[i-1].rstrip()}")

HighlightList()
