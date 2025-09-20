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
vim.opt.wildmenu = true
vim.opt.wildmode = { "list:longest", "full" }
vim.opt.wildignorecase = true
vim.opt.cursorline = true
vim.opt.helplang = "cn"

vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.updatetime = 100
vim.opt.scrolloff = 2
vim.opt.ttyfast = true
vim.opt.lazyredraw = true
vim.opt.synmaxcol = 501

vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
        if vim.fn.line([['"]]) > 0 and vim.fn.line([['"]]) <= vim.fn.line("$") then
            vim.cmd('normal! g`"')
        end
    end,
})

vim.g.markdown_recommended_style = 0
vim.g.c_no_curly_error = 1

vim.opt.autowrite = true
vim.api.nvim_create_autocmd("FocusLost", { command = "silent! wa" })
-- vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, { command = "silent! update" })
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

vim.o.background = "dark"
vim.cmd("colorscheme peachpuff")

vim.cmd('packadd termdebug')
vim.g.termdebug_config = {
    -- 调试器命令
    command = 'gdb',
    -- 禁用 K 键映射
    -- map_K = false,
    -- 禁用 - 键映射
    -- map_minus = false,
    -- 禁用 + 键映射
    -- map_plus = false,
    -- 禁用弹出菜单
    -- popup = 0,
    -- 禁用窗口工具条
    winbar = 0,
    -- 设置窗口宽度
    wide = 63,
    -- 使用提示模式
    -- use_prompt = true,
    -- 显示汇编窗口
    -- disasm_window = true,
    -- 汇编窗口高度
    -- disasm_window_height = 15,
    -- 显示变量窗口
    -- variables_window = true,
    -- 变量窗口高度
    -- variables_window_height = 5,
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

-- require("config.lazy").setup({
--     { "stevearc/aerial.nvim" },                -- 代码结构大纲
--     { "tyru/caw.vim" },                        -- 注释插件
--     { "lukas-reineke/indent-blankline.nvim" }, -- 缩进线
--     { "folke/lazy.nvim" },                     -- 插件管理器本身
--     -- { "onsails/lspkind.nvim" },                -- 补全图标
--     { "nvim-lualine/lualine.nvim" },           -- 状态栏
--     -- { "bufferline.nvim" },     -- 顶部状态栏
--     -- { "williamboman/mason.nvim" },             -- LSP/DAP/Linter 管理
--     { "echasnovski/mini.pairs" },          -- 自动补全括号
--     { "kylechui/nvim-surround" },          -- 包围符操作
--     { "nvim-tree/nvim-tree.lua" },         -- 文件树
--     { "nvim-treesitter/nvim-treesitter" }, -- 语法高亮
--     -- { "nvim-treesitter/nvim-treesitter-textobjects" }, -- treesitter 文本对象
--     -- { "nvim-tree/nvim-web-devicons" },         -- 文件图标
--     { "romainl/vim-cool" },                -- 搜索高亮消除
--     { "kshenoy/vim-signature" },           -- mark 管理
--     { "yianwillis/vimcdoc" },              -- 中文文档
--     { "HiPhish/rainbow-delimiters.nvim" }, -- 彩虹括号
--     { "neoclide/coc.nvim" },               -- 智能补全
--     {"mhinz/vim-startify"},                -- 启动页管理
--     {"OXY2DEV/markviwe.nvim"}              -- markdown预览
--     {"nvim-tree/nvim-web-devicons"}        -- 图标
--     {"h-hg/fcitx.nvim"},                   --
-- })
