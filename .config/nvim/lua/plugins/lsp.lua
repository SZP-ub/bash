--@diagnostic disable: undefined-global

return {
	---------------------------------------------------------------------------
	-- 1. mason.nvim：LSP / DAP / 代码格式化 / 工具 安装管理器
	--    只负责“安装”和“管理安装的工具”，不负责启动 LSP
	---------------------------------------------------------------------------
	{
		"mason-org/mason.nvim",
		-- event = "VeryLazy",
		opts = {
			ui = {
				-- mason 界面边框样式
				border = "rounded",
				-- mason 窗口大小（相对于编辑器宽高的比例）
				width = 0.8,
				height = 0.7,
				-- mason 列表图标：已安装、安装中、未安装
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
		config = function(_, opts)
			-- 初始化 mason
			require("mason").setup(opts)
		end,
	},

	---------------------------------------------------------------------------
	-- 2. mason-lspconfig.nvim：
	--    - 用 mason 安装 LSP server
	--    - 把安装好的 server 接到 Neovim 内置 LSP（这里用的是 0.11+ 新 API）
	---------------------------------------------------------------------------
	{
		"mason-org/mason-lspconfig.nvim",
		event = "VeryLazy",
		dependencies = {
			-- 依赖 mason.nvim，确保先加载 mason
			{ "mason-org/mason.nvim", opts = {} },
		},
		opts = {
			-- 自动安装的 LSP server 名称（与 nvim-lspconfig / mason registry 名字一致）
			ensure_installed = { "clangd", "lua_ls", "marksman", "pyright", "jsonls" },
			-- 当配置里需要的 server 未安装时，自动用 mason 安装
			automatic_installation = true,
		},
		config = function(_, opts)
			local mason_lspconfig = require("mason-lspconfig")
			-- 按上面的 opts 初始化 mason-lspconfig
			mason_lspconfig.setup(opts)

			-------------------------------------------------------------------
			-- 2.1 LSP 公共按键绑定（在 LspAttach 事件里设置）
			--     只在当前 buffer 成功 attach LSP 时生效
			-------------------------------------------------------------------
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					-- 小工具：简化 keymap 设置
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, {
							buffer = event.buf,
							desc = "LSP: " .. desc,
							silent = true,
						})
					end

					-- ======= 跳转、重命名、代码操作 等常用 LSP 快捷键 =======
					map("gd", vim.lsp.buf.definition, "[G]oto [D]efinition") -- 跳转到定义
					-- map("gr", vim.lsp.buf.references, "[G]oto [R]eferences") -- 查找引用
					map("gi", vim.lsp.buf.implementation, "[G]oto [I]mplementation") -- 跳转到实现
					map("grt", vim.lsp.buf.type_definition, "Type [D]efinition") -- 跳转到类型定义

					map("K", vim.lsp.buf.hover, "Hover Documentation") -- 悬浮文档（光标处符号说明）
					map("grn", vim.lsp.buf.rename, "[R]e[n]ame") -- 重命名符号
					map("gra", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" }) -- 代码操作（修复、重构等）
					map("grd", vim.lsp.buf.declaration, "[G]oto [D]eclaration") -- 跳转到声明

					map("[g", vim.diagnostic.goto_prev, "Previous Diagnostic") -- 上一个诊断
					map("]g", vim.diagnostic.goto_next, "Next Diagnostic") -- 下一个诊断

					-- 当前 buffer attach 上的 LSP client
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					local function client_supports_method(method, bufnr)
						return client and client:supports_method(method, bufnr)
					end

					-------------------------------------------------------------------
					-- 2.1.1 高亮当前符号（documentHighlight）
					--       光标停留时高亮同名引用，移动后清除
					-------------------------------------------------------------------
					if
						client_supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf)
						and vim.bo[event.buf].filetype ~= "bigfile"
					then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })

						-- 停下（Normal / Insert）时请 LSP 做高亮
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						-- 光标移动时清除高亮
						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						-- LSP 断开时清理相关 autocmd
						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(ev)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({
									group = "kickstart-lsp-highlight",
									buffer = ev.buf,
								})
							end,
						})
					end

					-------------------------------------------------------------------
					-- 2.1.2 Inlay hints 开关（0.11 原生）
					--       快捷键：<leader>th
					-------------------------------------------------------------------
					if client_supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(
								not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }),
								{ bufnr = event.buf }
							)
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			-------------------------------------------------------------------
			-- 2.2 全局诊断和 Hover 配置
			-------------------------------------------------------------------
			vim.diagnostic.config({
				severity_sort = true, -- 按严重程度排序
				float = { border = "rounded", source = "if_many" }, -- 浮动窗口风格
				underline = { severity = vim.diagnostic.severity.ERROR }, -- 只下划线 ERROR
				signs = {
					-- 左侧 signcolumn 图标
					text = {
						[vim.diagnostic.severity.ERROR] = "󰅚 ",
						[vim.diagnostic.severity.WARN] = "󰀪 ",
						[vim.diagnostic.severity.INFO] = "󰋽 ",
						[vim.diagnostic.severity.HINT] = "󰌶 ",
					},
				},
				virtual_text = {
					source = "if_many",
					spacing = 2,
					format = function(diagnostic)
						-- 虚拟文本只显示诊断消息本身
						return diagnostic.message
					end,
				},
			})

			-- Hover 文档使用圆角边框
			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })

			-------------------------------------------------------------------
			-- 2.3 把 nvim-cmp 的能力注入所有 LSP（全局默认能力）
			-------------------------------------------------------------------
			local base_capabilities = vim.lsp.protocol.make_client_capabilities()
			local capabilities = require("cmp_nvim_lsp").default_capabilities(base_capabilities)

			-- Neovim 0.11 新 API：对所有 server 应用默认 capabilities
			vim.lsp.config("*", {
				capabilities = capabilities,
			})

			-------------------------------------------------------------------
			-- 2.4 为每个 LSP server 定义专门配置（使用 root_dir 自动推断工程根目录）
			-------------------------------------------------------------------
			local function root_with(markers)
				-- 从当前 buffer 开始，向上查找包含这些文件/目录的路径作为 root_dir
				return vim.fs.root(0, markers)
			end

			-- 2.4.1 clangd：C / C++ / ObjC / CUDA
			vim.lsp.config("clangd", {
				name = "clangd",
				cmd = { "clangd" },
				filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
				root_dir = root_with({
					".clangd",
					".clang-tidy",
					".clang-format",
					"compile_commands.json",
					"compile_flags.txt",
					"configure.ac",
					".git",
				}),
				-- 对 clangd 做一些能力增强
				capabilities = vim.tbl_deep_extend("force", capabilities, {
					textDocument = { completion = { editsNearCursor = true } },
					offsetEncoding = { "utf-8", "utf-16" },
				}),
				-- 和 clangd 的 offsetEncoding 协商
				on_init = function(client, init_result)
					if init_result and init_result.offsetEncoding then
						client.offset_encoding = init_result.offsetEncoding
					end
				end,
			})

			-- 2.4.2 lua-language-server：Lua
			vim.lsp.config("lua_ls", {
				name = "lua_ls",
				filetypes = { "lua" },
				root_dir = root_with({
					".luarc.json",
					".luarc.jsonc",
					".git",
				}),
				settings = {
					Lua = {
						workspace = { checkThirdParty = false }, -- 不去弹第三方库提示
						hint = { enable = true }, -- 开启内联提示（需要配合上面的 inlay hints）
					},
				},
			})

			-- 2.4.3 marksman：Markdown LSP
			vim.lsp.config("marksman", {
				name = "marksman",
				cmd = { "marksman", "server" },
				filetypes = { "markdown", "markdown.mdx" },
				root_dir = root_with({ ".git" }),
			})

			-- 2.4.4 pyright：Python
			vim.lsp.config("pyright", {
				name = "pyright",
				cmd = { "pyright-langserver", "--stdio" },
				filetypes = { "python" },
				root_dir = root_with({
					"pyrightconfig.json",
					"pyproject.toml",
					"setup.py",
					"setup.cfg",
					"requirements.txt",
					"Pipfile",
					".git",
				}),
			})

			-- 2.4.5 jsonls：JSON / JSONC（vscode-json-language-server）
			vim.lsp.config("jsonls", {
				name = "jsonls",
				cmd = { "vscode-json-language-server", "--stdio" },
				filetypes = { "json", "jsonc" },
				root_dir = root_with({
					"package.json",
					"tsconfig.json",
					".git",
				}),
				settings = {
					json = {
						validate = { enable = true }, -- 启用 JSON 校验
					},
				},
			})

			-------------------------------------------------------------------
			-- 2.5 启用这些 LSP server（自动按 filetype attach，无需 :LspStart）
			-------------------------------------------------------------------
			vim.lsp.enable({
				"clangd",
				"lua_ls",
				"marksman",
				"pyright",
				"jsonls",
			})

			-------------------------------------------------------------------
			-- 2.6 用户命令：组织 imports（类似 coc 中的 Fold / OR）
			-------------------------------------------------------------------
			-- :Fold        -> 仅做 organizeImports（range 版）
			-- vim.api.nvim_create_user_command("Fold", function()
			-- 	vim.lsp.buf.range_code_action({ only = { "source.organizeImports" } })
			-- end, { nargs = "?" })

			-- :OR          -> 仅做 organizeImports（全局 code_action 版）
			-- vim.api.nvim_create_user_command("OR", function()
			-- 	vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } } })
			-- end, {})
		end,
	},

	---------------------------------------------------------------------------
	-- 3. nvim-cmp：自动补全（插入模式、命令行、搜索）
	--    - 补全来源：LSP / buffer / path / snippet
	--    - Tab / S-Tab 智能跳转（补全列表、snippet、括号对）
	---------------------------------------------------------------------------
	{
		"hrsh7th/nvim-cmp",
		event = "VeryLazy", -- 打开 Neovim 一段时间后再加载，避免启动阻塞
		dependencies = {
			"hrsh7th/cmp-nvim-lsp", -- LSP 完成源
			"saadparwaiz1/cmp_luasnip", -- LuaSnip snippet 完成源
			"hrsh7th/cmp-buffer", -- buffer 文本完成源
			"hrsh7th/cmp-path", -- 文件路径完成源
			"L3MON4D3/LuaSnip", -- snippet 引擎
			"hrsh7th/cmp-cmdline", -- 命令行完成源
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			-------------------------------------------------------------------
			-- 3.1 加载 SnipMate 格式的 snippets（从 ~/.config/nvim/snippets）
			-------------------------------------------------------------------
			require("luasnip.loaders.from_snipmate").lazy_load({
				paths = { vim.fn.stdpath("config") .. "/snippets" },
			})

			-------------------------------------------------------------------
			-- 3.2 与 mini.pairs / 任意自动补全括号联动的“智能 Tab / S-Tab”
			--     - 若右侧是闭合括号/引号，Tab 直接跳出
			--     - 否则退化为真正的 <Tab>/<S-Tab>
			-------------------------------------------------------------------
			local function jump_out_pair_forward_or_tab()
				local row, col = unpack(vim.api.nvim_win_get_cursor(0))
				local line = vim.api.nvim_get_current_line()
				local next_char = line:sub(col + 1, col + 1)
				if next_char:match("[%)%]%}'\"`]") then
					-- 右侧是闭合符号：直接把光标移到其后面
					vim.api.nvim_win_set_cursor(0, { row, col + 1 })
				else
					-- 否则退化为真正的 <Tab>
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
				end
			end

			local function jump_out_pair_backward_or_stab()
				local row, col = unpack(vim.api.nvim_win_get_cursor(0))
				local line = vim.api.nvim_get_current_line()
				local prev_char = line:sub(col, col)
				if prev_char:match("[%(%[%{'\"`]") then
					-- 左侧是开括号/引号：向左跳一格
					vim.api.nvim_win_set_cursor(0, { row, math.max(col - 1, 0) })
				else
					-- 否则退化为真正的 <S-Tab>
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<S-Tab>", true, false, true), "n", false)
				end
			end

			-------------------------------------------------------------------
			-- 3.3 补全项 kind 对应的图标（用于美化补全列表）
			-------------------------------------------------------------------
			local kind_icons = {
				Text = "󰉿",
				Method = "󰆧",
				Function = "󰊕",
				Constructor = "",
				Field = "󰜢",
				Variable = "󰀫",
				Class = "󰠱",
				Interface = "",
				Module = "",
				Property = "󰜢",
				Unit = "",
				Value = "󰎠",
				Enum = "",
				Keyword = "󰌋",
				Snippet = "",
				Color = "󰏘",
				File = "󰈙",
				Reference = "󰈇",
				Folder = "󰉋",
				EnumMember = "",
				Constant = "󰏿",
				Struct = "󰙅",
				Event = "",
				Operator = "󰆕",
				TypeParameter = "",
			}

			-------------------------------------------------------------------
			-- 3.4 主补全配置（插入模式）
			-------------------------------------------------------------------
			cmp.setup({
				-- 告诉 nvim-cmp 如何展开 snippet
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},

				-- 插入模式下的快捷键映射
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(), -- 手动触发补全
					["<CR>"] = cmp.mapping.confirm({ select = true }), -- 回车确认当前选中项（如果没有则选中第一个）

					["<Tab>"] = cmp.mapping(function()
						if cmp.visible() then
							-- 补全菜单可见：下一个候选
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							-- 若 snippet 可展开或可跳转：走 snippet
							luasnip.expand_or_jump()
						else
							-- 否则尝试“跳出括号”；再退化为真正 Tab
							jump_out_pair_forward_or_tab()
						end
					end, { "i", "s" }),

					["<S-Tab>"] = cmp.mapping(function()
						if cmp.visible() then
							-- 补全菜单可见：上一个候选
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							-- 反向跳 snippet
							luasnip.jump(-1)
						else
							-- 否则尝试“反向跳出括号”；再退化为真正 S-Tab
							jump_out_pair_backward_or_stab()
						end
					end, { "i", "s" }),

					["<C-b>"] = cmp.mapping.scroll_docs(-4), -- 向上滚动文档
					["<C-f>"] = cmp.mapping.scroll_docs(4), -- 向下滚动文档
				}),

				-- 传统菜单体验：使用 Vim 自身的 completeopt 逻辑
				completion = {
					completeopt = "menu,menuone,noinsert",
					keyword_length = 2, -- 输入 ≥2 个字符才自动弹补全
				},

				-- 补全项的显示形式（图标 + 文本 + 来源标签）
				formatting = {
					fields = { "kind", "abbr", "menu" },
					format = function(entry, vim_item)
						-- 左边图标 + 类型名称
						vim_item.kind = (kind_icons[vim_item.kind] or "") .. " " .. vim_item.kind

						-- 右侧的 menu 来源标记
						vim_item.menu = ({
							luasnip = "[Snip]", -- snippet 来源
							buffer = "[Buf]", -- 当前 buffer
							path = "[Path]", -- 文件路径
							nvim_lsp = "[LSP]", -- LSP
						})[entry.source.name] or ""

						return vim_item
					end,
				},

				-- 补全来源的优先级和顺序
				sources = cmp.config.sources({
					{ name = "luasnip" }, -- snippet
					{ name = "buffer" }, -- buffer 单词
					{ name = "path" }, -- 文件路径
					{ name = "nvim_lsp" }, -- LSP
				}),

				-- 关闭 ghost text（若主题里没有配颜色，容易看不清）
				experimental = {
					ghost_text = true,
				},
				-- 不填写 window，使用 cmp 默认无边框菜单
			})

			-------------------------------------------------------------------
			-- 3.5 命令行模式补全（:）：
			--     - 完成命令名、路径、最近 buffer 内容
			-------------------------------------------------------------------
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "cmdline" }, -- : 后的命令补全
					{ name = "path" }, -- 路径补全
					{ name = "buffer" }, -- 当前 / 最近 buffer 内容
				}),
				completion = {
					completeopt = "menu,menuone,noinsert",
				},
				-- 不设置 window，保持默认无边框传统样式
			})

			-------------------------------------------------------------------
			-- 3.6 搜索模式补全（/ 和 ?）：
			--     - 从 buffer / path / cmdline 源里给出候选
			-------------------------------------------------------------------
			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "buffer" }, -- 当前 buffer 文本
					{ name = "path" }, -- 路径字符串
					{ name = "cmdline" }, -- 之前输入过的命令/搜索
				}),
				completion = {
					completeopt = "menu,menuone,noinsert",
				},
				-- 同样不设置 window，沿用默认传统菜单
			})

			-------------------------------------------------------------------
			-- 3.7 进入命令行时自动触发补全（: / / / ?）
			-------------------------------------------------------------------
			for _, pat in ipairs({ ":", "/", "?" }) do
				vim.api.nvim_create_autocmd("CmdlineEnter", {
					pattern = pat,
					callback = function()
						vim.schedule(function()
							require("cmp").complete()
						end)
					end,
				})
			end
		end,
	},

	---------------------------------------------------------------------------
	-- 4. nvim-treesitter-textobjects：
	--    - 函数/类/参数 文本对象（af/if/ac/ic/ap/ip）
	--    - 函数间移动（]f [f ]F [F）
	--    - 参数交换（gsp / gsP）
	--    - LSP Peek 预览（gpf / gpc）
	---------------------------------------------------------------------------
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},

		-- 为 lazy.nvim 声明会用到的按键（用于懒加载提示）
		keys = {
			-- 文本对象（用于 operator-pending 和可视模式）
			{ "af", mode = { "o", "x" } }, -- a f：函数整体
			{ "if", mode = { "o", "x" } }, -- i f：函数内部
			{ "ac", mode = { "o", "x" } }, -- a c：类/结构体整体
			{ "ic", mode = { "o", "x" } }, -- i c：类/结构体内部
			{ "ap", mode = { "o", "x" } }, -- a p：参数整体
			{ "ip", mode = { "o", "x" } }, -- i p：参数内部

			-- 函数移动
			{ "]f", mode = "n" }, -- 下一个函数开头
			{ "[f", mode = "n" }, -- 上一个函数开头
			{ "]F", mode = "n" }, -- 下一个函数结尾
			{ "[F", mode = "n" }, -- 上一个函数结尾

			-- 参数交换
			{ "gsp", mode = "n" }, -- 当前参数与下一个参数交换
			{ "gsP", mode = "n" }, -- 当前参数与上一个参数交换

			-- LSP Peek 预览函数 / 类代码块
			{ "gpf", mode = "n" }, -- 预览函数定义块
			{ "gpc", mode = "n" }, -- 预览类/结构体定义块
		},

		config = function()
			require("nvim-treesitter.configs").setup({
				-- 自动安装 / 启用的解析器
				ensure_installed = { "lua", "python", "javascript", "typescript", "c", "cpp", "java" },
				highlight = { enable = true }, -- 语法高亮
				indent = { enable = true }, -- Treesitter 缩进

				textobjects = {
					-------------------------------------------------------------------
					-- 4.1 文本对象 select：af/if/ac/ic/ap/ip
					-------------------------------------------------------------------
					select = {
						enable = true,
						lookahead = true, -- 类似 targets.vim，输入文本对象后自动向前查找
						keymaps = {
							["af"] = "@function.outer", -- 函数整体
							["if"] = "@function.inner", -- 函数内部
							["ac"] = "@class.outer", -- 类/结构体整体
							["ic"] = "@class.inner", -- 类/结构体内部
							["ap"] = "@parameter.outer", -- 参数整体
							["ip"] = "@parameter.inner", -- 参数内部
						},
						-- 某些文本对象用 charwise 选择（v 模式）
						selection_modes = {
							["@parameter.outer"] = "v",
							["@function.outer"] = "v",
						},
						include_surrounding_whitespace = false, -- 不自动包含前后空白
					},

					-------------------------------------------------------------------
					-- 4.2 move：函数级别跳转（]f [f ]F [F）
					-------------------------------------------------------------------
					move = {
						enable = true,
						set_jumps = true, -- 把跳转记录到 jumplist，便于 <C-o> 返回
						goto_next_start = {
							["]f"] = "@function.outer",
						},
						goto_next_end = {
							["]F"] = "@function.outer",
						},
						goto_previous_start = {
							["[f"] = "@function.outer",
						},
						goto_previous_end = {
							["[F"] = "@function.outer",
						},
					},

					-------------------------------------------------------------------
					-- 4.3 swap：交换参数位置（gsp / gsP）
					-------------------------------------------------------------------
					swap = {
						enable = true,
						swap_next = {
							["gsp"] = "@parameter.inner",
						},
						swap_previous = {
							["gsP"] = "@parameter.inner",
						},
					},

					-------------------------------------------------------------------
					-- 4.4 lsp_interop：Treesitter + LSP Peek 定义
					-------------------------------------------------------------------
					lsp_interop = {
						enable = true,
						peek_definition_code = {
							["gpf"] = "@function.outer", -- 预览函数定义
							["gpc"] = "@class.outer", -- 预览类/结构体定义
						},
					},
				},
			})
		end,
	},
}
