---@diagnostic disable: undefined-global

return {
	-- =========================
	-- mason-tool-installer：格式化 / lint 工具自动安装
	-- =========================
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		-- 只有当你真正开始编辑文件时才需要这些工具，延后到 BufReadPre/BufNewFile
		event = { "BufReadPre", "BufNewFile" },
		-- event = "VeryLazy",
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
				run_on_start = true, -- mason.nvim 初始化后首次进入 buffer 时自动执行
			})
		end,
	},

	-- =========================
	-- conform.nvim：保存时自动格式化
	-- =========================
	{
		"stevearc/conform.nvim",
		-- 只有在开始编辑文件、或准备写入时才需要格式化逻辑
		event = { "BufReadPre", "BufNewFile" },
		-- event = "VeryLazy",
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
					markdown = { "prettier" },
					yaml = { "prettier" },
					html = { "prettier" },
					css = { "prettier" },
					javascript = { "prettier" },
					typescript = { "prettier" },
				},
				formatters = {
					prettier = {
						-- 4 空格缩进
						prepend_args = { "--tab-width", "4" },
					},
				},
				format_on_save = {
					lsp_fallback = true,
					timeout_ms = 300,
				},
			})

			-- 如果你更想显式控制，而不是全局 format_on_save，
			-- 可以把上面的 format_on_save 去掉，改成按需创建 autocmd，例如：
			-- vim.api.nvim_create_autocmd("BufWritePre", {
			--   callback = function(args)
			--     require("conform").format({ bufnr = args.buf })
			--   end,
			-- })
		end,
	},

	-- =========================
	-- nvim-lint：保存后自动 lint（仅在用到时加载）
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

			lint.linters_by_ft = {
				json = {}, -- 显式禁用 json lint（包括 jsonlint）
				markdown = { "codespell" },
				-- lua = { "codespell" },
				-- c = { "codespell" },
				-- cpp = { "codespell" },
			}

			-- 只在保存后对当前 buffer 运行一次 lint
			vim.api.nvim_create_autocmd("BufWritePost", {
				group = vim.api.nvim_create_augroup("nvim-lint-auto", { clear = true }),
				callback = function(args)
					-- 只在普通 buffer 上 lint，避免 quickfix/terminal 等
					if vim.bo[args.buf].buftype ~= "" then
						return
					end
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
		-- 懒加载：只有执行 :Trouble 或按你映射的快捷键时才加载
		cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
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
			local ok, trouble = pcall(require, "trouble")
			if not ok then
				return
			end
			trouble.setup(opts)

			-- 如果需要 lualine 集成，建议在你的 lualine 配置文件里引入：
			-- sections = {
			--   lualine_c = { require("trouble").statusline },
			-- }
		end,
	},
}
