---@diagnostic disable: undefined-global
vim.opt.autoindent = true
vim.opt.cindent = false
vim.cmd("filetype indent off")

vim.g.mapleader = "\\"
vim.opt.compatible = false
vim.opt.wrap = true
vim.opt.swapfile = false
vim.cmd("syntax enable")
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
-- vim.opt.clipboard = "unnamedplus"
vim.opt.errorbells = false
vim.opt.visualbell = true
vim.opt.wildignorecase = true
vim.opt.cursorline = true
vim.opt.helplang = "cn"

vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.updatetime = 100
vim.opt.scrolloff = 3
vim.opt.ttyfast = true
vim.opt.lazyredraw = true
vim.opt.synmaxcol = 501

vim.g.markdown_recommended_style = 0
vim.g.c_no_curly_error = 1

vim.opt.autowrite = true
vim.api.nvim_create_autocmd("focuslost", { command = "silent! wa" })

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.o.pumheight = 8
vim.o.pumwidth = 30
vim.o.pumblend = 0

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.o.background = "light"
-- vim.cmd("colorscheme peachpuff")
vim.cmd("colorscheme retrobox")

-- ======================== Folding config ===========================
vim.o.viewoptions = vim.o.viewoptions:match("folds") and vim.o.viewoptions or (vim.o.viewoptions .. ",folds")

local g = vim.api.nvim_create_augroup("RememberFolds", { clear = true })
-- 关闭/删除 buffer 时保存视图（包含折叠）
vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout", "BufUnload" }, {
    pattern = "*",
    command = "silent! mkview",
    group = g,
})
-- 打开/读取 buffer 时恢复视图（包含折叠）
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
    pattern = "*",
    command = "silent! loadview",
    group = g,
})

-- ======== Return to last edit position when opening files =======
local augroup = vim.api.nvim_create_augroup("LastEditPosition", { clear = true })
vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup,
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
            vim.cmd("normal! zz") -- 跳转后居中光标
        end
    end,
})

-- =================== 补全菜单配置 ====================
vim.o.wildmenu = true
vim.o.wildmode = "longest:full,full"
vim.o.wildoptions = "pum"

-- ============= unity test ==================
vim.g.ultest_deprecation_notice = 0
vim.g['test#c#runner'] = 'custom_c'
vim.g['test#custom_c#file_pattern'] = 'test_.*\\.c$'
vim.g['test#custom_c#command'] = 'cd test && ./test_runner'

-- =================== godbolt ====================
vim.api.nvim_create_autocmd({ "bufwinenter", "winenter" }, {
    pattern = "*",
    callback = function()
        if vim.bo.filetype == "asm" and vim.bo.buftype == "nofile" then
            vim.wo.number = true
        end
    end,
})

-- ====================== termdebug ===================

vim.api.nvim_set_keymap('t', '<esc>', [[<c-\><c-n>]], { noremap = true })
vim.opt.timeout = false
vim.opt.ttimeout = true
vim.opt.timeoutlen = 100

vim.cmd('packadd termdebug')

-- 设置窗口大小
vim.api.nvim_create_autocmd("User", {
    pattern = "TermdebugStartPost",
    callback = function()
        -- 批量获取窗口ID，减少多次调用
        local win_ids = vim.api.nvim_list_wins()
        local win2, win3, win4 = win_ids[2], win_ids[3], win_ids[4]
        -- 判断窗口是否存在
        if not win2 or not win3 or not win4 then
            vim.notify("窗口 2、3 或 4 不存在", vim.log.levels.WARN)
            return
        end
        -- 用窗口4的buffer替换窗口2的buffer，然后关闭窗口4
        local buf4 = vim.api.nvim_win_get_buf(win4)
        vim.api.nvim_win_set_buf(win2, buf4)
        vim.api.nvim_win_close(win4, true)
        -- 交换窗口2和窗口3的buffer
        local buf2 = vim.api.nvim_win_get_buf(win2)
        local buf3 = vim.api.nvim_win_get_buf(win3)
        vim.api.nvim_win_set_buf(win2, buf3)
        vim.api.nvim_win_set_buf(win3, buf2)
        -- 窗口2高度减半
        local cur_height = vim.api.nvim_win_get_height(win2)
        if cur_height > 1 then
            vim.api.nvim_win_set_height(win2, math.max(1, math.floor(cur_height / 2)))
        end
        -- 新增：将光标聚焦到窗口2
        vim.api.nvim_set_current_win(win2)
        vim.cmd("normal! G")
        vim.api.nvim_set_current_win(win3)
    end
})

vim.g.termdebug_config = {
    -- 调试器命令
    command = 'gdb',
    -- 禁用 k 键映射
    -- map_k = false,
    -- 禁用 - 键映射
    -- map_minus = false,
    -- 禁用 + 键映射
    -- map_plus = false,
    -- 禁用弹出菜单
    -- popup = 0,
    -- 禁用窗口工具条
    winbar = 0,
    -- 设置窗口宽度
    wide = 163,
    -- 使用提示模式
    -- use_prompt = true,

    -- term = reverse,
    -- ctermbg = lightblue,
    -- guibg = lightblue,

    -- 显示汇编窗口
    -- disasm_window = true,
    -- 汇编窗口高度
    -- disasm_window_height = 15,
    -- 显示变量窗口
    variables_window = true,
    -- 变量窗口高度
    variables_window_height = 9,
    -- 断点符号
    -- sign = '>>',
    -- 断点编号用十进制显示
    sign_decimal = 1,
    -- 弹窗显示表达式计算结果
    evaluate_in_popup = true,
}

-- 记得在 require("config.lazy") 之前加载 keymaps
require("keymaps")

require("config.lazy")
