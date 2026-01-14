---@diagnostic disable: undefined-global

-- vim.g.python3_host_prog = os.getenv("HOME") .. "/.local/share/nvim-venv/bin/python"
local opt = vim.opt
local o = vim.o
local g = vim.g
local api = vim.api

-----------------------------------------------------------------------
-- 基本缩进与文件类型行为
-----------------------------------------------------------------------
opt.autoindent = true -- 新行继承上一行缩进
opt.cindent = false -- 关闭 C 风格自动缩进
vim.cmd("filetype indent off") -- 不使用默认 filetype 缩进脚本（完全自己控制）

-----------------------------------------------------------------------
-- Leader 与兼容性
-----------------------------------------------------------------------
g.mapleader = "\\" -- 自定义 leader 键为反斜杠
opt.compatible = false -- 关闭兼容模式，启用现代 Vim/Neovim 特性

-----------------------------------------------------------------------
-- 显示与文件行为
-----------------------------------------------------------------------
opt.swapfile = false -- 不生成 swap 文件
opt.backup = false -- 不生成备份文件
opt.writebackup = false -- 写入时不产生备份
opt.signcolumn = "yes" -- 始终显示左侧标志栏，避免抖动
vim.cmd("syntax enable") -- 启用语法高亮
vim.o.mouse = "a" -- 启用鼠标模式（在某些情况下有助于调整分割窗口大小）
vim.o.showmode = false -- 因为状态栏已经显示模式，所以不用再显示模式文本
vim.o.breakindent = true -- 启用断行缩进（保持缩进层次）
opt.number = true -- 显示行号
opt.relativenumber = true -- 相对行号
opt.termguicolors = true -- 24-bit 颜色

-- ★ 这里加入 conceal 相关设置（对 markview / LaTeX 渲染很重要）
vim.o.conceallevel = 2
vim.o.concealcursor = "nc"

-- opt.clipboard = "unnamedplus" -- 如需与系统剪贴板互通可启用
opt.errorbells = false -- 关闭错误响铃
opt.visualbell = false -- 视觉提示代替声音
opt.cursorline = true -- 高亮当前行
opt.helplang = "cn" -- 优先中文帮助

-----------------------------------------------------------------------
-- 补全/命令行行为
-----------------------------------------------------------------------
opt.wildignorecase = true -- 命令行补全忽略大小写
o.wildmenu = true
o.wildmode = "longest:full,full"
o.wildoptions = "pum"

-----------------------------------------------------------------------
-- 搜索
-----------------------------------------------------------------------
opt.hlsearch = true -- 高亮搜索结果
opt.incsearch = true -- 增量搜索
opt.ignorecase = true -- 搜索默认忽略大小写
opt.smartcase = true -- 搜索包含大写时切换为区分大小写
o.inccommand = "nosplit" -- :s 等命令实时预览（不分屏）

-----------------------------------------------------------------------
-- 编辑行为
-----------------------------------------------------------------------
opt.backspace = { "indent", "eol", "start" } -- backspace 更智能
opt.updatetime = 100 -- CursorHold / 诊断延迟（ms）
vim.o.timeoutlen = 300 -- 减少映射序列等待时间
opt.scrolloff = 1 -- 上下预留 3 行
-- opt.ttyfast = true -- 老选项，现代终端几乎无影响
opt.lazyredraw = true -- 执行宏/复杂命令时延迟重绘
opt.synmaxcol = 501 -- 语法高亮最大列数，超出跳过以提速

-----------------------------------------------------------------------
-- 换行策略：默认开启，Markdown 中关闭
-----------------------------------------------------------------------
opt.wrap = true -- 全局默认自动换行

api.nvim_create_autocmd({ "FileType", "BufReadPost", "BufWinEnter" }, {
	pattern = { "*.md", "markdown" },
	callback = function()
		vim.opt_local.wrap = false
		vim.cmd("silent! Markview render")
	end,
})

-----------------------------------------------------------------------
-- set *.h filetype = c
-----------------------------------------------------------------------
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.h",
	callback = function()
		vim.bo.filetype = "c"
	end,
})

-----------------------------------------------------------------------
-- 文件类型/插件兼容
-----------------------------------------------------------------------
g.markdown_recommended_style = 0 -- 使用自定义 markdown 样式
g.c_no_curly_error = 0 -- 保留 C 语言 { } 报错（或按需调整）

-----------------------------------------------------------------------
-- 缩进与制表符
-----------------------------------------------------------------------
opt.tabstop = 4 -- <Tab> 显示宽度
opt.shiftwidth = 4 -- 自动缩进宽度
opt.expandtab = true -- 用空格代替 Tab
opt.smartindent = true -- 智能缩进（适合编程）

-----------------------------------------------------------------------
-- 补全菜单外观
-----------------------------------------------------------------------
o.pumheight = 8 -- 补全菜单最多显示 8 项
o.pumwidth = 30 -- 补全菜单宽度（有些 UI 不一定严格遵守）
o.pumblend = 0 -- 补全菜单不透明

-----------------------------------------------------------------------
-- 窗口拆分方向
-----------------------------------------------------------------------
opt.splitbelow = true -- 水平分割在下方
opt.splitright = true -- 垂直分割在右侧

-----------------------------------------------------------------------
-- 主题与背景
-----------------------------------------------------------------------
o.background = "dark" -- 使用暗色背景
vim.cmd("colorscheme peachpuff") -- 确保已安装对应 colorscheme

-----------------------------------------------------------------------
-- 光标 / 占位符 / 选区 高亮（强对比）
-----------------------------------------------------------------------
-- 光标：黑底亮绿字
-- api.nvim_set_hl(0, "Cursor", { fg = "#00ff00", bg = "#000000", bold = true })
-- 当前行背景：略深，便于定位
-- api.nvim_set_hl(0, "CursorLine", { bg = "#2f2f2f" })

-- LuaSnip 占位符：与光标完全区分开的紫/蓝色块
-- api.nvim_set_hl(0, "LuasnipInsertNode", { bg = "#552255", fg = "#ffffff", italic = true })
-- api.nvim_set_hl(0, "LuasnipChoiceNode", { bg = "#334488", fg = "#ffffff", italic = true })

-- 选区：橙色块，避免和上面混在一起
api.nvim_set_hl(0, "Visual", { bg = "#f5c195", fg = "NONE" })

-----------------------------------------------------------------------
-- fzf.vim：在 fzf buffer 中 ESC 直接退出
-----------------------------------------------------------------------
api.nvim_create_autocmd("FileType", {
	pattern = "fzf",
	callback = function()
		api.nvim_buf_set_keymap(0, "t", "<Esc>", "<C-c>", { noremap = true, silent = true })
	end,
})

-----------------------------------------------------------------------
-- 复制高亮提示
-----------------------------------------------------------------------
api.nvim_set_hl(0, "YankHighlight", { bg = "#cccccc", fg = "NONE" })
api.nvim_create_autocmd("TextYankPost", {
	desc = "highlight copying text",
	group = api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank({ higroup = "YankHighlight", timeout = 500 })
	end,
})

-----------------------------------------------------------------------
-- 折叠状态记忆（mkview/loadview）
-----------------------------------------------------------------------
-- o.viewoptions = o.viewoptions:match("folds") and o.viewoptions or (o.viewoptions .. ",folds")
--
-- local folds_group = api.nvim_create_augroup("RememberFolds", { clear = true })
--
-- -- 关闭/删除 buffer 时保存视图（包含折叠）
-- api.nvim_create_autocmd({ "BufDelete", "BufWipeout", "BufUnload" }, {
-- 	pattern = "*",
-- 	command = "silent! mkview",
-- 	group = folds_group,
-- })
--
-- -- 打开/读取 buffer 时恢复视图（包含折叠）
-- api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
-- 	pattern = "*",
-- 	command = "silent! loadview",
-- 	group = folds_group,
-- })

-----------------------------------------------------------------------
-- 打开文件回到上次光标位置
-----------------------------------------------------------------------
-- local last_pos_group = api.nvim_create_augroup("LastEditPosition", { clear = true })
-- api.nvim_create_autocmd("BufReadPost", {
-- 	group = last_pos_group,
-- 	callback = function()
-- 		local mark = api.nvim_buf_get_mark(0, '"')
-- 		local lcount = api.nvim_buf_line_count(0)
-- 		if mark[1] > 0 and mark[1] <= lcount then
-- 			pcall(api.nvim_win_set_cursor, 0, mark)
-- 			vim.cmd("normal! zz")
-- 		end
-- 	end,
-- })

-----------------------------------------------------------------------
-- vim-test / ult test：C 单元测试
-----------------------------------------------------------------------
g.ultest_deprecation_notice = 0
g["test#c#runner"] = "custom_c"
g["test#custom_c#file_pattern"] = "test_.*\\.c$"
g["test#custom_c#command"] = "cd test && ./test_runner"

-----------------------------------------------------------------------
-- godbolt：asm buffer 辅助显示
-----------------------------------------------------------------------
api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
	pattern = "*",
	callback = function()
		if vim.bo.filetype == "asm" and vim.bo.buftype == "nofile" then
			vim.wo.number = true
		end
	end,
})

-----------------------------------------------------------------------
-- termdebug 配置
-----------------------------------------------------------------------
-- 终端模式 Esc 回到常规模式
api.nvim_set_keymap("t", "<Esc>", [[<C-\><C-n>]], { noremap = true })

-- 超时设置
opt.timeout = false
opt.ttimeout = true
opt.timeoutlen = 100

-- 加载 termdebug 插件
vim.cmd("packadd termdebug")

-- 调整 termdebug 布局
api.nvim_create_autocmd("User", {
	pattern = "TermdebugStartPost",
	callback = function()
		local win_ids = api.nvim_list_wins()
		local win2, win3, win4 = win_ids[2], win_ids[3], win_ids[4]
		if not (win2 and win3 and win4) then
			vim.notify("窗口 2、3 或 4 不存在", vim.log.levels.WARN)
			return
		end

		-- 用窗口4的 buffer 替换窗口2，然后关闭窗口4
		local buf4 = api.nvim_win_get_buf(win4)
		api.nvim_win_set_buf(win2, buf4)
		api.nvim_win_close(win4, true)

		-- 交换窗口2和窗口3的 buffer（注意使用 nvim_win_get_buf）
		local buf2 = api.nvim_win_get_buf(win2)
		local buf3 = api.nvim_win_get_buf(win3)
		api.nvim_win_set_buf(win2, buf3)
		api.nvim_win_set_buf(win3, buf2)

		-- 窗口2高度减半
		local cur_height = api.nvim_win_get_height(win2)
		if cur_height > 1 then
			api.nvim_win_set_height(win2, math.max(1, math.floor(cur_height / 2)))
		end

		-- 焦点依次切到 win2 底部、再回到 win3
		api.nvim_set_current_win(win2)
		vim.cmd("normal! G")
		api.nvim_set_current_win(win3)
	end,
})

-- termdebug 配置（保留你原来的字段）
vim.g.termdebug_config = {
	command = "gdb", -- 调试器命令
	winbar = 0, -- 禁用窗口工具条
	wide = 163, -- 主窗口宽度
	variables_window = true, -- 显示变量窗口
	variables_window_height = 9,
	sign_decimal = 1, -- 断点编号十进制
	evaluate_in_popup = true, -- 弹窗显示表达式结果
	-- 其它开关按需再打开：
	-- map_k = false,
	-- map_minus = false,
	-- map_plus = false,
	-- popup = 0,
	-- disasm_window = true,
	-- disasm_window_height = 15,
}

-----------------------------------------------------------------------
-- 折叠、keymaps 与 lazy.nvim 的加载（保持你原有流程）
-----------------------------------------------------------------------
require("keymaps")
require("config.lazy")
