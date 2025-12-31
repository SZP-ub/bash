---@diagnostic disable: undefined-global
return {

	{
		"nvim-lua/plenary.nvim",
		lazy = true,
	},

	{
		"p00f/godbolt.nvim",
		keys = {
			{ "<leader>gb", "<cmd>Godbolt<CR>", desc = "打开 Godbolt" },
		},
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("godbolt").setup({
				languages = {
					cpp = { compiler = "g122", options = {} },
					c = { compiler = "cg122", options = {} },
				},
				auto_cleanup = true,
				highlight = {
					cursor = "Visual",
					static = false,
				},
				quickfix = {
					enable = true,
					auto_open = true,
				},
				url = "https://godbolt.org",
			})
		end,
	},
}
