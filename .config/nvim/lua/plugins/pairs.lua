---@diagnostic disable: undefined-global
return {

	-- =========================
	-- mini.pairs：自动补全括号/引号
	-- =========================
	{
		"echasnovski/mini.pairs",
		event = "InsertEnter",
		config = function()
			local pairs = require("mini.pairs")

			-- 使用基本默认配置即可，mappings 保持常见括号/引号补全
			pairs.setup({
				mappings = {
					["("] = { action = "open", pair = "()", neigh_pattern = "[^\\].", register = { cr = false } },
					["["] = { action = "open", pair = "[]", neigh_pattern = "[^\\].", register = { cr = false } },
					["{"] = { action = "open", pair = "{}", neigh_pattern = "[^\\].", register = { cr = false } },

					[")"] = { action = "close", pair = "()", neigh_pattern = "[^\\]." },
					["]"] = { action = "close", pair = "[]", neigh_pattern = "[^\\]." },
					["}"] = { action = "close", pair = "{}", neigh_pattern = "[^\\]." },

					['"'] = { action = "closeopen", pair = '""', neigh_pattern = "[^\\].", register = { cr = false } },
					["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^\\].", register = { cr = false } },
					["`"] = { action = "closeopen", pair = "``", neigh_pattern = "[^\\].", register = { cr = false } },
				},
			})
		end,
	},

	{
		"tpope/vim-repeat",
		lazy = true,
	},

	{
		"kylechui/nvim-surround",
		dependencies = { "tpope/vim-repeat" },
		version = "*",
		keys = {
			{ "ys", mode = { "n", "x" }, desc = "添加包裹" },
			{ "ds", mode = "n", desc = "删除包裹" },
			{ "cs", mode = "n", desc = "更改包裹" },
		},
		config = function()
			require("nvim-surround").setup()
			vim.keymap.set("x", "ys", "<Plug>(nvim-surround-visual)", { silent = true })
		end,
		-- 快捷键示例（无需额外配置，插件自动生效）：
		-- ysiw) ：用括号包裹当前单词
		-- ys$" ：用双引号包裹到行尾
		-- ds] ：删除方括号包裹
		-- dst ：删除 HTML 标签包裹
		-- cs'" ：将单引号包裹改为双引号
		-- csth1<CR> ：将标签包裹改为 h1 标签
		-- dsf ：删除函数调用的括号包裹
	},

	{
		"HiPhish/rainbow-delimiters.nvim",
		event = "VeryLazy",
		version = "*",
		config = function()
			require("rainbow-delimiters.setup").setup({
				strategy = {
					[""] = "rainbow-delimiters.strategy.global",
					vim = "rainbow-delimiters.strategy.local",
				},
				query = {
					[""] = "rainbow-delimiters",
					lua = "rainbow-blocks",
				},
				priority = {
					[""] = 110,
					lua = 210,
				},
			})
			vim.cmd([[
	  hi MatchParen guibg=#444444 guifg=#ff8800 gui=bold
	]])
		end,
	},
}
