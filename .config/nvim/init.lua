---@diagnostic disable: undefined-global

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

opt.number = true -- 显示行号
opt.relativenumber = true -- 相对行号
opt.termguicolors = true -- 24-bit 颜色
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
opt.scrolloff = 1 -- 上下预留 3 行
-- opt.ttyfast = true -- 老选项，现代终端几乎无影响
opt.lazyredraw = true -- 执行宏/复杂命令时延迟重绘
opt.synmaxcol = 501 -- 语法高亮最大列数，超出跳过以提速

-----------------------------------------------------------------------
-- 换行策略：默认开启，Markdown 中关闭
-----------------------------------------------------------------------
opt.wrap = true -- 全局默认自动换行
api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.opt_local.wrap = false
	end,
})

-----------------------------------------------------------------------
-- 文件类型/插件兼容
-----------------------------------------------------------------------
g.markdown_recommended_style = 1 -- 使用自定义 markdown 样式
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
-- vim.cmd("colorscheme retrobox")

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
o.viewoptions = o.viewoptions:match("folds") and o.viewoptions or (o.viewoptions .. ",folds")

local folds_group = api.nvim_create_augroup("RememberFolds", { clear = true })

-- 关闭/删除 buffer 时保存视图（包含折叠）
api.nvim_create_autocmd({ "BufDelete", "BufWipeout", "BufUnload" }, {
	pattern = "*",
	command = "silent! mkview",
	group = folds_group,
})

-- 打开/读取 buffer 时恢复视图（包含折叠）
api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	pattern = "*",
	command = "silent! loadview",
	group = folds_group,
})

-----------------------------------------------------------------------
-- 打开文件回到上次光标位置
-----------------------------------------------------------------------
local last_pos_group = api.nvim_create_augroup("LastEditPosition", { clear = true })
api.nvim_create_autocmd("BufReadPost", {
	group = last_pos_group,
	callback = function()
		local mark = api.nvim_buf_get_mark(0, '"')
		local lcount = api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(api.nvim_win_set_cursor, 0, mark)
			vim.cmd("normal! zz")
		end
	end,
})

-----------------------------------------------------------------------
-- Mason 安装工具 PATH（按需启用）
-----------------------------------------------------------------------
-- local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
-- if not string.find(vim.env.PATH or "", mason_bin, 1, true) then
--   vim.env.PATH = mason_bin .. ":" .. (vim.env.PATH or "")
-- end

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
api.nvim_set_keymap("t", "<Esc>", [[<C-\><C-n>]], { noremap = true })
opt.timeout = false
opt.ttimeout = true
opt.timeoutlen = 100

vim.cmd("packadd termdebug")

-- 调整 termdebug 布局
api.nvim_create_autocmd("User", {
	pattern = "TermdebugStartPost",
	callback = function()
		local win_ids = api.nvim_list_wins()
		local win2, win3, win4 = win_ids[2], win_ids[3], win_ids[4]
		if not win2 or not win3 or not win4 then
			vim.notify("窗口 2、3 或 4 不存在", vim.log.levels.WARN)
			return
		end

		-- 用窗口4的 buffer 替换窗口2，然后关闭窗口4
		local buf4 = api.nvim_win_get_buf(win4)
		api.nvim_win_set_buf(win2, buf4)
		api.nvim_win_close(win4, true)

		-- 交换窗口2和窗口3的 buffer
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

g.termdebug_config = {
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
-- 加载 keymaps 与 lazy.nvim
-----------------------------------------------------------------------
require("keymaps")
require("config.lazy")

-- -- 基本缩进与文件类型行为
-- vim.opt.autoindent = true -- 自动缩进（新行继承上一行缩进）
-- vim.opt.cindent = false -- 关闭 C 风格的自动缩进（使用更简单的 smartindent）
-- vim.cmd("filetype indent off") -- 关闭 filetype 提供的 indent 脚本（如果你想自己控制缩进恢复为 on）
--
-- -- 全局 leader 键与兼容性
-- vim.g.mapleader = "\\" -- 自定义 leader 键为反斜杠
-- vim.opt.compatible = false -- 关闭兼容模式，启用现代 Vim/Neovim 特性
--
-- -- 显示与文件行为
-- vim.opt.swapfile = false -- 关闭 swapfile（避免临时文件）
-- vim.opt.backup = false -- 关闭备份文件（避免与 LSP 等交互时产生兼容问题）
-- vim.opt.writebackup = false -- 关闭写入备份（与 backup 配合）
-- vim.opt.signcolumn = "yes" -- 总是显示左侧标志栏（避免文本抖动）
-- vim.cmd("syntax enable") -- 启用语法高亮
-- vim.opt.number = true -- 显示行号
-- vim.opt.relativenumber = true -- 显示相对行号（当前行为绝对行号）
-- vim.opt.termguicolors = true -- 启用 24-bit 颜色支持
-- -- vim.opt.clipboard = "unnamedplus" -- 如果想与系统剪贴板互通可以启用
-- vim.opt.errorbells = false -- 关闭错误提示声音
-- vim.opt.visualbell = true -- 使用可视提示代替声音
-- vim.opt.wildignorecase = true -- 补全命令时忽略大小写
-- vim.opt.smartcase = true
-- vim.opt.cursorline = true -- 高亮当前行
-- vim.opt.helplang = "cn" -- 帮助文档首选语言（中文）
--
-- -- 搜索
-- vim.opt.hlsearch = true -- 高亮搜索结果
-- vim.opt.incsearch = true -- 增量搜索（输入时高亮匹配）
-- vim.opt.ignorecase = true -- 搜索忽略大小写（除非包含大写）
-- vim.o.inccommand = "nosplit" -- 正则表达式
--
-- -- 编辑行为
-- vim.opt.backspace = { "indent", "eol", "start" } -- backspace 更智能
-- vim.opt.updatetime = 100 -- CursorHold 与诊断延迟（毫秒），较低值更灵敏但更频繁写入
-- vim.opt.scrolloff = 3 -- 光标上下保留 3 行上下文
-- vim.opt.ttyfast = true -- 终端优化提示（老选项，通常设置无害）
-- vim.opt.lazyredraw = true -- 在执行宏/复杂命令时延迟重绘以提高速度
-- vim.opt.synmaxcol = 501 -- 语法高亮最大列数，超出后跳过以节省 CPU
-- -- vim.opt.winborder = 'rounded' -- 如果需要可以设置窗口边框样式（部分 UI 插件使用）
--
-- -- 全局默认开启换行
-- vim.opt.wrap = true
--
-- -- 仅在 markdown 中关闭换行
-- vim.api.nvim_create_autocmd("FileType", {
-- 	pattern = "markdown",
-- 	callback = function()
-- 		vim.opt_local.wrap = false -- 只对当前 buffer 生效
-- 	end,
-- })
--
-- -- 文件类型/插件兼容
-- vim.g.markdown_recommended_style = 1 -- 取消 markdown.lua 推荐样式（如果使用自定义主题）
-- vim.g.c_no_curly_error = 0 -- C 文件中关闭某些报错（与 coc/c 相关）
--
-- -- 缩进与制表符
-- vim.opt.tabstop = 4 -- Tab 显示宽度
-- vim.opt.shiftwidth = 4 -- 自动缩进时的宽度
-- vim.opt.expandtab = true -- 使用空格代替 Tab 字符
-- vim.opt.smartindent = true -- 智能缩进（适合编程）
--
-- -- 补全菜单外观
-- vim.o.pumheight = 8 -- 补全菜单高度
-- vim.o.pumwidth = 30 -- 补全菜单宽度（窗口管理器可能会忽略）
-- vim.o.pumblend = 0 -- 补全菜单透明度（0 为不透明）
--
-- -- 窗口拆分方向
-- vim.opt.splitbelow = true -- 新窗口在下方
-- vim.opt.splitright = true -- 新窗口在右侧
--
-- -- 主题与背景
-- -- vim.o.background = "light"
-- vim.o.background = "dark" -- 主题使用暗色背景（确保颜色方案匹配）
-- vim.cmd("colorscheme peachpuff") -- 加载 colorscheme（确保已安装 peachpuff）
-- -- vim.cmd("colorscheme retrobox")
--
-- -- ========================= fzf.vim - config ========================
-- -- ESC 直接退出 fzf，针对终端 buffer 映射
-- vim.api.nvim_create_autocmd("FileType", {
-- 	pattern = "fzf",
-- 	callback = function()
-- 		vim.api.nvim_buf_set_keymap(0, "t", "<Esc>", "<C-c>", { noremap = true, silent = true })
-- 	end,
-- })
--
-- -- ========================= 复制高亮提示 ==========================
-- vim.api.nvim_set_hl(0, "YankHighlight", { bg = "#cccccc", fg = "NONE" }) -- 只设置背景色
-- -- vim.api.nvim_set_hl(0, "YankHighlight", { bg = "#f5c195", fg = "NONE" }) -- 只设置背景色
--
-- vim.api.nvim_create_autocmd("TextYankPost", {
-- 	desc = "highlight copying text",
-- 	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
-- 	callback = function()
-- 		vim.highlight.on_yank({ higroup = "YankHighlight", timeout = 500 })
-- 	end,
-- })
--
-- -- ======================== Folding config ===========================
-- vim.o.viewoptions = vim.o.viewoptions:match("folds") and vim.o.viewoptions or (vim.o.viewoptions .. ",folds")
--
-- local g = vim.api.nvim_create_augroup("RememberFolds", { clear = true })
-- -- 关闭/删除 buffer 时保存视图（包含折叠）
-- vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout", "BufUnload" }, {
-- 	pattern = "*",
-- 	command = "silent! mkview",
-- 	group = g,
-- })
-- -- 打开/读取 buffer 时恢复视图（包含折叠）
-- vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
-- 	pattern = "*",
-- 	command = "silent! loadview",
-- 	group = g,
-- })
--
-- -- ======== Return to last edit position when opening files =======
-- local augroup = vim.api.nvim_create_augroup("LastEditPosition", { clear = true })
-- vim.api.nvim_create_autocmd("BufReadPost", {
-- 	group = augroup,
-- 	callback = function()
-- 		local mark = vim.api.nvim_buf_get_mark(0, '"')
-- 		local lcount = vim.api.nvim_buf_line_count(0)
-- 		if mark[1] > 0 and mark[1] <= lcount then
-- 			pcall(vim.api.nvim_win_set_cursor, 0, mark)
-- 			vim.cmd("normal! zz") -- 跳转后居中光标
-- 		end
-- 	end,
-- })
--
-- -- =================== 补全菜单配置 ====================
-- vim.o.wildmenu = true
-- vim.o.wildmode = "longest:full,full"
-- vim.o.wildoptions = "pum"
--
-- -- ==================== Mason 安装工具 PATH ================
-- -- local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
-- -- if not string.find(vim.env.PATH or "", mason_bin, 1, true) then
-- -- 	vim.env.PATH = mason_bin .. ":" .. (vim.env.PATH or "")
-- -- end
--
-- -- ============= unity test ==================
-- vim.g.ultest_deprecation_notice = 0
-- vim.g["test#c#runner"] = "custom_c"
-- vim.g["test#custom_c#file_pattern"] = "test_.*\\.c$"
-- vim.g["test#custom_c#command"] = "cd test && ./test_runner"
--
-- -- =================== godbolt ====================
-- vim.api.nvim_create_autocmd({ "bufwinenter", "winenter" }, {
-- 	pattern = "*",
-- 	callback = function()
-- 		if vim.bo.filetype == "asm" and vim.bo.buftype == "nofile" then
-- 			vim.wo.number = true
-- 		end
-- 	end,
-- })
--
-- -- ====================== termdebug ===================
--
-- vim.api.nvim_set_keymap("t", "<esc>", [[<c-\><c-n>]], { noremap = true })
-- vim.opt.timeout = false
-- vim.opt.ttimeout = true
-- vim.opt.timeoutlen = 100
--
-- vim.cmd("packadd termdebug")
--
-- -- 设置窗口大小
-- vim.api.nvim_create_autocmd("User", {
-- 	pattern = "TermdebugStartPost",
-- 	callback = function()
-- 		-- 批量获取窗口ID，减少多次调用
-- 		local win_ids = vim.api.nvim_list_wins()
-- 		local win2, win3, win4 = win_ids[2], win_ids[3], win_ids[4]
-- 		-- 判断窗口是否存在
-- 		if not win2 or not win3 or not win4 then
-- 			vim.notify("窗口 2、3 或 4 不存在", vim.log.levels.WARN)
-- 			return
-- 		end
-- 		-- 用窗口4的buffer替换窗口2的buffer，然后关闭窗口4
-- 		local buf4 = vim.api.nvim_win_get_buf(win4)
-- 		vim.api.nvim_win_set_buf(win2, buf4)
-- 		vim.api.nvim_win_close(win4, true)
-- 		-- 交换窗口2和窗口3的buffer
-- 		local buf2 = vim.api.nvim_win_get_buf(win2)
-- 		local buf3 = vim.api.nvim_win_get_buf(win3)
-- 		vim.api.nvim_win_set_buf(win2, buf3)
-- 		vim.api.nvim_win_set_buf(win3, buf2)
-- 		-- 窗口2高度减半
-- 		local cur_height = vim.api.nvim_win_get_height(win2)
-- 		if cur_height > 1 then
-- 			vim.api.nvim_win_set_height(win2, math.max(1, math.floor(cur_height / 2)))
-- 		end
-- 		-- 新增：将光标聚焦到窗口2
-- 		vim.api.nvim_set_current_win(win2)
-- 		vim.cmd("normal! G")
-- 		vim.api.nvim_set_current_win(win3)
-- 	end,
-- })
--
-- vim.g.termdebug_config = {
-- 	-- 调试器命令
-- 	command = "gdb",
-- 	-- 禁用 k 键映射
-- 	-- map_k = false,
-- 	-- 禁用 - 键映射
-- 	-- map_minus = false,
-- 	-- 禁用 + 键映射
-- 	-- map_plus = false,
-- 	-- 禁用弹出菜单
-- 	-- popup = 0,
-- 	-- 禁用窗口工具条
-- 	winbar = 0,
-- 	-- 设置窗口宽度
-- 	wide = 163,
-- 	-- 使用提示模式
-- 	-- use_prompt = true,
--
-- 	-- term = reverse,
-- 	-- ctermbg = lightblue,
-- 	-- guibg = lightblue,
--
-- 	-- 显示汇编窗口
-- 	-- disasm_window = true,
-- 	-- 汇编窗口高度
-- 	-- disasm_window_height = 15,
-- 	-- 显示变量窗口
-- 	variables_window = true,
-- 	-- 变量窗口高度
-- 	variables_window_height = 9,
-- 	-- 断点符号
-- 	-- sign = '>>',
-- 	-- 断点编号用十进制显示
-- 	sign_decimal = 1,
-- 	-- 弹窗显示表达式计算结果
-- 	evaluate_in_popup = true,
-- }
--
-- -- 记得在 require("config.lazy") 之前加载 keymaps
-- require("keymaps")
--
-- require("config.lazy")
