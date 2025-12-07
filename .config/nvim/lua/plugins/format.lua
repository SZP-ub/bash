---@diagnostic disable: undefined-global
return {
	-- =========================
	-- 格式化工具自动安装
	-- =========================
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim", -- 自动安装常用格式化工具
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					"clang-format", -- C/C++
					"stylua", -- Lua
					"prettier", -- JSON/Markdown/YAML/HTML/CSS/JS/TS/Markdown
					"codespell", -- 拼写检查
				},
				auto_update = true,
				run_on_start = true,
			})
		end,
	},

	-- =========================
	-- conform.nvim：保存时自动格式化
	-- =========================
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					c = { "clang_format" },
					cpp = { "clang_format" },
					lua = { "stylua" },
					json = { "prettier" },
					markdown = { "prettier" },
					yaml = { "prettier" },
					html = { "prettier" },
					css = { "prettier" },
					javascript = { "prettier" },
					typescript = { "prettier" },
				},
				formatters = {
					prettier = {
						prepend_args = { "--tab-width", "4" }, -- 关键：设置为 4 空格
					},
				},
				format_on_save = {
					lsp_fallback = true,
					timeout_ms = 300,
				},
			})
		end,
	},

	-- =========================
	-- nvim-lint：保存时自动 lint
	-- =========================

	{
		"mfussenegger/nvim-lint",
		event = "BufWritePost",
		config = function()
			local lint = require("lint")

			-- 显式指定各 filetype 用哪些 linter
			lint.linters_by_ft = {
				json = {}, -- 关键行：禁用 json 的所有 linter（包括 jsonlint）
				markdown = { "codespell" },
				lua = { "codespell" },
				c = { "codespell" },
				cpp = { "codespell" },
			}

			vim.api.nvim_create_autocmd("BufWritePost", {
				callback = function()
					lint.try_lint() -- 按上面 linters_by_ft 跑
					-- 如果你已经在 linters_by_ft 里给各语言加了 codespell
					-- 这里的单独 `try_lint("codespell")` 就可以去掉，避免重复
					-- lint.try_lint("codespell")
				end,
			})
		end,
	},

	-- =========================
	-- Trouble：诊断/quickfix/LSP 列表可视化
	-- =========================
	{
		"folke/trouble.nvim", -- 诊断、LSP、quickfix等信息的可视化展示
		cmd = "Trouble", -- 懒加载
		opts = {
			focus = false,
			warn_no_results = false,
			open_no_results = true,
			preview = {
				type = "float",
				relative = "editor",
				border = "rounded",
				title = "Preview",
				title_pos = "center",
				position = { 0.3, 0.3 },
				size = { width = 0.6, height = 0.5 },
				zindex = 200,
			},
		},
		config = function(_, opts)
			require("trouble").setup(opts)
			-- Trouble 状态栏推荐集成方式（参考 Trouble 官方文档）
			-- 如果需要 lualine 集成，推荐如下方式，而不是直接修改 lualine 配置对象
			-- require("lualine").setup({
			--   sections = {
			--     lualine_c = { require("trouble").statusline },
			--   }
			-- })
		end,
	},
}
