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
vim.opt.scrolloff = 1
vim.opt.ttyfast = true
vim.opt.lazyredraw = true
vim.opt.synmaxcol = 501

vim.api.nvim_create_autocmd("bufreadpost", {
    callback = function()
        if vim.fn.line([['"]]) > 0 and vim.fn.line([['"]]) <= vim.fn.line("$") then
            vim.cmd('normal! g`"')
        end
    end,
})

vim.g.markdown_recommended_style = 0
vim.g.c_no_curly_error = 1

vim.opt.autowrite = true
vim.api.nvim_create_autocmd("focuslost", { command = "silent! wa" })
-- vim.api.nvim_create_autocmd({ "cursorhold", "cursorholdi" }, { command = "silent! update" })
-- vim.opt.updatetime = 600000

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

-- =================== 补全菜单配置 ====================
vim.o.wildmenu = true
vim.o.wildmode = "longest:full,full"
vim.o.wildoptions = "pum"

-- ================== fzf.vim环境配置 ================
vim.env.fzf_default_opts =
'--layout=reverse --no-wrap --bind=tab:down,ctrl-n:toggle+down,shift-tab:up,ctrl-p:toggle+up'

-- ============= unity test ==================
vim.g.ultest_deprecation_notice = 0
vim.g['test#c#runner'] = 'custom_c'
vim.g['test#custom_c#file_pattern'] = 'test_.*\\.c$'
vim.g['test#custom_c#command'] = 'cd test && ./test_runner'

-- ============ 自动保存：切换 buffer 或窗口时 ==============
vim.api.nvim_create_autocmd({ "bufleave", "winleave" }, {
    pattern = "*",
    callback = function()
        if vim.bo.modified and vim.bo.buftype == "" then
            vim.cmd("silent! write")
        end
    end,
})

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

vim.api.nvim_create_autocmd("user", {
    pattern = "termdebugstartpost",
    callback = function()
        vim.cmd("resize 22")
        vim.cmd("wincmd r")
    end
})

vim.cmd('packadd termdebug')
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
