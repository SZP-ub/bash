---@diagnostic disable: undefined-global
return {
	-- =========================
	-- mason-tool-installer：格式化 / lint 工具自动安装
	-- =========================
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		-- 只有当你真正开始编辑文件时才需要这些工具
		-- 使用 BufReadPre/BufNewFile 懒加载，避免影响启动
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			-- 用你已经在别处配置的 mason 包名，避免重复引入
			"mason-org/mason.nvim",
		},
		config = function()
			local ok, mti = pcall(require, "mason-tool-installer")
			if not ok then
				return
			end

			mti.setup({
				ensure_installed = {
					"clang-format", -- C/C++
					"stylua", -- Lua
					"prettier", -- JSON/Markdown/YAML/HTML/CSS/JS/TS
					"codespell", -- 拼写检查
				},
				auto_update = true,
				-- mason.nvim 初始化后首次进入 buffer 时自动执行
				run_on_start = true,
			})
		end,
	},

	-- =========================
	-- conform.nvim：手动触发“先格式化再保存”
	-- =========================
	{
		"stevearc/conform.nvim",
		-- 用 keys 懒加载：第一次按快捷键时才加载插件
		keys = {
			-- 普通模式：<space>w -> 先格式化，再 :write
			{
				"<space>w",
				function()
					local conform = require("conform")
					-- 先同步格式化当前 buffer
					conform.format({
						lsp_fallback = true,
						timeout_ms = 2000,
					})
					-- 再执行真正的写入
					vim.cmd("write")
				end,
				mode = "n",
				desc = "Format buffer and write",
			},
		},

		config = function()
			local ok, conform = pcall(require, "conform")
			if not ok then
				return
			end

			conform.setup({
				formatters_by_ft = {
					c = { "clang_format" },
					cpp = { "clang_format" },
					lua = { "stylua" },
					json = { "prettier" },
					jsonc = { "prettier" },
					markdown = { "prettier" },
					["markdown.mdx"] = { "prettier" },
					yaml = { "prettier" },
					html = { "prettier" },
					css = { "prettier" },
					javascript = { "prettier" },
					typescript = { "prettier" },
					javascriptreact = { "prettier" },
					typescriptreact = { "prettier" },
				},
				formatters = {
					prettier = {
						-- 4 空格缩进
						prepend_args = { "--tab-width", "4" },
					},
				},
				-- 不启用全局 format_on_save，完全由快捷键 <space>w 控制
			})

			-- 如果你以后又想恢复“自动保存前格式化”，可以改成：
			-- vim.api.nvim_create_autocmd("BufWritePre", {
			--   group = vim.api.nvim_create_augroup("ConformFormatOnSave", { clear = true }),
			--   callback = function(args)
			--     if vim.bo[args.buf].buftype ~= "" then
			--       return
			--     end
			--     conform.format({ bufnr = args.buf, lsp_fallback = true, timeout_ms = 2000 })
			--   end,
			-- })
		end,
	},

	-- =========================
	-- nvim-lint：保存后自动 lint（codespell 结果进 Trouble / 虚拟文本）
	-- =========================
	{
		"mfussenegger/nvim-lint",
		-- 写入时才真正需要 lint，延后加载
		event = "BufWritePost",
		config = function()
			local ok, lint = pcall(require, "lint")
			if not ok then
				return
			end

			-- 在需要时再开启对应文件类型的 linter
			lint.linters_by_ft = {
				-- json = {}, -- 若想显式禁用 json lint，可保留这一行
				markdown = { "codespell" },
				-- 如果你愿意，也可以给其它语言加上拼写检查：
				lua = { "codespell" },
				c = { "codespell" },
				cpp = { "codespell" },
			}

			-- 只在保存后对当前 buffer 运行一次 lint
			vim.api.nvim_create_autocmd("BufWritePost", {
				group = vim.api.nvim_create_augroup("nvim-lint-auto", { clear = true }),
				callback = function(args)
					-- 只在普通 buffer 上 lint，避免 quickfix/terminal 等
					if vim.bo[args.buf].buftype ~= "" then
						return
					end
					-- 这里的诊断会进入 vim.diagnostic，
					-- Trouble 与虚拟文本会和 LSP 诊断统一显示
					lint.try_lint() -- 使用 linters_by_ft 的配置
				end,
			})
		end,
	},

	-- =========================
	-- Trouble：诊断 / quickfix / LSP 列表可视化
	-- =========================
	{
		"folke/trouble.nvim",
		keys = {

			-- <leader>gd：文档诊断列表（Trouble diagnostics）
			-- 显示当前 buffer 的 LSP/编译错误、警告等诊断信息
			{ "<leader>gd", "<CMD>Trouble diagnostics toggle<CR>", desc = "[Trouble] Toggle buffer diagnostics" },

			-- <leader>gs：文档符号列表（Trouble symbols）
			-- 显示当前 buffer 的函数、结构体、变量等 LSP 文档符号，不抢焦点，仅在侧边栏浏览
			{ "<leader>gs", "<CMD>Trouble symbols toggle focus=false<CR>", desc = "[Trouble] Toggle symbols " },

			-- <leader>gl：LSP 结果列表（Trouble lsp）
			-- 在右侧打开 LSP 定义 / 引用 / 实现 / 类型定义等综合列表，不抢焦点，作为侧边导航使用
			{
				"<leader>gl",
				"<CMD>Trouble lsp toggle focus=false win.position=right<CR>",
				desc = "[Trouble] Toggle LSP definitions/references/...",
			},

			-- <leader>gL：Location List 列表（Trouble loclist）
			-- 使用 Trouble 界面浏览当前窗口的 location list（一般由 :lopen / 部分插件填充）
			{ "<leader>gL", "<CMD>Trouble loclist toggle<CR>", desc = "[Trouble] Location List" },

			-- <leader>gq：Quickfix 列表（Trouble qflist）
			-- 使用 Trouble 界面浏览 quickfix 列表（编译结果、grep 结果等）
			{ "<leader>gq", "<CMD>Trouble qflist toggle<CR>", desc = "[Trouble] Quickfix List" },

			-- 下面这些是基于 LSP 的 Trouble 映射示例，目前被注释掉，如需直接打开对应列表可解开注释
			-- grr：LSP 引用列表（Trouble lsp_references）
			-- { "grr", "<CMD>Trouble lsp_references focus=true<CR>",         mode = { "n" }, desc = "[Trouble] LSP references"                        }, -- 显示引用列表
			-- gD：LSP 声明列表（Trouble lsp_declarations）
			-- { "gD", "<CMD>Trouble lsp_declarations focus=true<CR>",        mode = { "n" }, desc = "[Trouble] LSP declarations"                      }, -- 显示声明列表
			-- gd：LSP 类型定义列表（Trouble lsp_type_definitions）
			-- { "gd", "<CMD>Trouble lsp_type_definitions focus=true<CR>",    mode = { "n" }, desc = "[Trouble] LSP type definitions"                  }, -- 显示类型定义列表
			-- gri：LSP 实现列表（Trouble lsp_implementations）
			-- { "gri", "<CMD>Trouble lsp_implementations focus=true<CR>",    mode = { "n" }, desc = "[Trouble] LSP implementations"                   }, -- 显示实现列表
		},

		specs = {
			"folke/snacks.nvim",
			event = "VeryLazy",
			-- 将 Trouble 的 actions 集成到 snacks.nvim 的 picker 里，
			-- 方便在 snacks 结果列表中一键用 Trouble 面板重新展示（例如诊断列表、文档符号列表等）
			opts = function(_, opts)
				return vim.tbl_deep_extend("force", opts or {}, {
					picker = {
						-- 使用 trouble 提供的 snacks 集成 actions：
						-- 比如在 snacks 中选择一个结果后，可以用 trouble_open 打开 Trouble 面板
						actions = require("trouble.sources.snacks").actions,
						win = {
							input = {
		                              -- stylua: ignore
		                              keys = {
		                                -- 在 snacks 的输入窗口中，Ctrl+t 调用 trouble_open 操作（支持 normal/insert 模式）
		                                -- 可以将当前 snacks 的结果集切换到 Trouble 面板浏览（包括文档符号列表、诊断列表等）
		                                ["<c-t>"] = { "trouble_open", mode = { "n", "i" }, },
		                              },
							},
						},
					},
				})
			end,
		},

		-- Trouble 全局配置
		opts = {
			-- 打开 Trouble 时不自动获取焦点，保持在原编辑窗口操作
			focus = false,
			-- 当没有结果时不显示警告，界面更安静
			warn_no_results = false,
			-- 即使没有结果也自动打开 Trouble 窗口，方便确认当前无诊断/无符号
			open_no_results = true,
			-- 预览窗口配置（用于在 Trouble 中预览选中的诊断/符号位置）
			preview = {
				type = "float", -- 使用浮动窗口预览
				relative = "editor", -- 相对整个编辑器定位
				-- border = "rounded",    -- 圆角边框（如需边框可取消注释）
				title = "Preview", -- 浮窗标题
				title_pos = "center", -- 标题置中
				---`row` and `col` values relative to the editor
				-- 浮窗在编辑器中的相对位置（行、列的百分比）
				position = { 0.3, 0.3 },
				-- 浮窗大小，占编辑器宽高的百分比
				size = { width = 0.6, height = 0.5 },
				zindex = 200, -- 浮窗层级，数值越大越在上层
			},
		},

		config = function(_, opts)
			-- 初始化 Trouble 插件（包括诊断列表、文档符号列表、LSP 结果列表等）
			require("trouble").setup(opts)

			-- 创建一个用于 lualine/winbar 的文档符号状态组件（基于 Trouble 的文档符号列表）
			local symbols = require("trouble").statusline({
				mode = "lsp_document_symbols", -- 使用 LSP 文档符号模式：与 Trouble symbols 列表同源数据
				groups = {}, -- 不做额外分组，按默认层级显示
				title = false, -- 不显示标题，仅显示符号本身
				filter = { range = true }, -- 仅显示当前可见范围内的符号，避免过长
				format = "{kind_icon}{symbol.name:Normal}", -- 显示“图标 + 符号名”，和文档符号列表风格一致

				-- The following line is needed to fix the background color
				-- Set it to the lualine section you want to use
				-- 下面这一行用来修正背景色，需要设置为你实际使用的 lualine section 高亮组
				hl_group = "lualine_b_normal",
			})

			-- Insert status into lualine
			-- 将 Trouble 的文档符号组件插入到 lualine 的 winbar 中，
			-- 形成一个“当前光标所在符号路径”的迷你文档符号列表（类似 breadcrumb）
			local lualine_ok, lualine = pcall(require, "lualine")
			if not lualine_ok then
				return
			end

			local lualine_opts = lualine.get_config() or {}

			-- 确保 winbar 和其中的 lualine_b 存在
			lualine_opts.winbar = lualine_opts.winbar or {}
			lualine_opts.winbar.lualine_b = lualine_opts.winbar.lualine_b or {}

			table.insert(lualine_opts.winbar.lualine_b, 1, {
				symbols.get, -- 实际渲染函数：展示当前文档符号信息
				cond = symbols.has, -- 仅在当前 buffer 有文档符号（LSP 支持）时显示
			})

			-- 使用更新后的配置重新设置 lualine
			lualine.setup(lualine_opts)
		end,
	},
}
