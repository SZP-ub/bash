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
					-- 开括号：在输入 ( [ { 时自动补上对应闭合符号
					["("] = { action = "open", pair = "()", neigh_pattern = "[^\\].", register = { cr = false } },
					["["] = { action = "open", pair = "[]", neigh_pattern = "[^\\].", register = { cr = false } },
					["{"] = { action = "open", pair = "{}", neigh_pattern = "[^\\].", register = { cr = false } },

					-- 关括号：在输入 ) ] } 时处理关闭行为（通常用于跳过或正确处理闭合）
					[")"] = { action = "close", pair = "()", neigh_pattern = "[^\\]." },
					["]"] = { action = "close", pair = "[]", neigh_pattern = "[^\\]." },
					["}"] = { action = "close", pair = "{}", neigh_pattern = "[^\\]." },

					-- 引号：使用 closeopen 模式，使得在插入引号时能够在双引号/单引号/反引号间智能切换
					['"'] = { action = "closeopen", pair = '""', neigh_pattern = "[^\\].", register = { cr = false } },
					["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^\\].", register = { cr = false } },
					["`"] = { action = "closeopen", pair = "``", neigh_pattern = "[^\\].", register = { cr = false } },
				},
			})
		end,
	},

	-- =========================
	-- tpope/vim-repeat：让 . 可以重复更多 plugin 操作
	-- =========================
	{
		"tpope/vim-repeat",
		lazy = true,
	},

	-- =========================
	-- mini.surround：替代 nvim-surround 的 surround 功能（添加/删除/替换环绕）
	-- =========================
	{
		"echasnovski/mini.surround",
		dependencies = { "tpope/vim-repeat" }, -- 保持与原 plugin 的 repeat 行为，以支持 . 重复
		keys = {
			{ "ys", mode = { "n", "x" }, desc = "添加包裹" }, -- operator-pending（n）和 visual（x）
			{ "ds", mode = "n", desc = "删除包裹" },
			{ "cs", mode = "n", desc = "更改包裹" },
		},
		config = function()
			require("mini.surround").setup({
				mappings = {
					add = "ys", -- 添加环绕（operator-pending / visual 都支持）
					delete = "ds", -- 删除环绕
					replace = "cs", -- 替换环绕
				},
			})
		end,
	},

	-- =========================
	-- rainbow-delimiters：彩虹括号（不同嵌套层级着不同颜色）
	-- =========================
	-- 说明：
	--  - 可选视觉增强插件，为嵌套括号（() {} []）上色，便于阅读复杂表达式/嵌套结构。
	--  - event = "VeryLazy" 表示非常懒加载（你也可以改为更具体的触发事件，例如 BufReadPost）。
	--  - config 中演示了如何设置 strategy、query 以及针对 matchparen 的高亮样式（示例中把匹配括号高亮为橙色粗体）。
	-- {
	-- 	"HiPhish/rainbow-delimiters.nvim",
	-- 	event = "VeryLazy",
	-- 	version = "*",
	-- 	config = function()
	-- 		require("rainbow-delimiters.setup").setup({
	-- 			strategy = {
	-- 				[""] = "rainbow-delimiters.strategy.global",
	-- 				vim = "rainbow-delimiters.strategy.local",
	-- 			},
	-- 			query = {
	-- 				[""] = "rainbow-delimiters",
	-- 				lua = "rainbow-blocks",
	-- 			},
	-- 			priority = {
	-- 				[""] = 110,
	-- 				lua = 210,
	-- 			},
	-- 		})
	-- 		-- 自定义匹配括号的高亮（可按需修改颜色）
	-- 		vim.cmd([[
	--   hi MatchParen guibg=#444444 guifg=#ff8800 gui=bold
	-- ]])
	-- 	end,
	-- },
}
