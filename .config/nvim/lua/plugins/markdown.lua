---@diagnostic disable: undefined-global
return {

	{
		"OXY2DEV/markview.nvim",
		ft = { "markdown" },
		priority = 100,
		config = function()
			local markview = require("markview")

			markview.setup({
				preview = {
					auto_start = true,
					icon_provider = "devicons", -- "mini" or "devicons"
				},

				bullets = {
					enabled = true,
					icons = { "●", "○", "◆", "◇" },
					ordered = function(ctx)
						local value = vim.trim(ctx.value)
						local index = tonumber(value:sub(1, #value - 1))
						return ("%d."):format(index > 1 and index or ctx.index)
					end,
				},

				checkboxes = {
					enabled = true,
					unchecked = {
						icon = "󰄱 ",
					},
					checked = {
						icon = "󰱒 ",
					},
					custom = {
						todo = {
							raw = "[-]",
							rendered = "󰥔 ",
						},
					},
				},

				quote = {
					enabled = true,
					icon = "▋",
				},

				links = {
					enabled = true,
				},

				callouts = {
					enabled = true,
					styles = {
						note = { icon = "󰋽 " },
						tip = { icon = "󰌶 " },
						important = { icon = "󰅾 " },
						warning = { icon = "󰀪 " },
						caution = { icon = "󰳦 " },
						info = { icon = "󰋽 " },
						success = { icon = "󰄬 " },
						danger = { icon = "󱐌 " },
						error = { icon = "󱐌 " },
						bug = { icon = "󰨰 " },
						quote = { icon = "󱆨 " },
						example = { icon = "󰉹 " },
					},
				},

				anti_conceal = {
					enabled = true,
					ignore = {
						code_background = true,
						sign = true,
					},
				},
			})
		end,
	},

	-- {
	-- 	"OXY2DEV/markview.nvim",
	-- 	ft = { "markdown" },
	-- 	priority = 100,
	-- 	config = function()
	-- 		local markview = require("markview")
	--
	-- 		markview.setup({
	-- 			preview = {
	-- 				auto_start = true,
	-- 				icon_provider = "devicons", -- "mini" or "devicons"
	-- 			},
	--
	-- 			bullets = {
	-- 				enabled = true,
	-- 				icons = { "●", "○", "◆", "◇" },
	-- 				ordered = function(ctx)
	-- 					local value = vim.trim(ctx.value)
	-- 					local index = tonumber(value:sub(1, #value - 1))
	-- 					return ("%d."):format(index > 1 and index or ctx.index)
	-- 				end,
	-- 			},
	--
	-- 			checkboxes = {
	-- 				enabled = true,
	-- 				unchecked = {
	-- 					icon = "󰄱 ",
	-- 				},
	-- 				checked = {
	-- 					icon = "󰱒 ",
	-- 				},
	-- 				custom = {
	-- 					todo = {
	-- 						raw = "[-]",
	-- 						rendered = "󰥔 ",
	-- 					},
	-- 				},
	-- 			},
	--
	-- 			quote = {
	-- 				enabled = true,
	-- 				icon = "▋",
	-- 			},
	--
	-- 			links = {
	-- 				enabled = true,
	-- 			},
	--
	-- 			callouts = {
	-- 				enabled = true,
	-- 				styles = {
	-- 					note = { icon = "󰋽 " },
	-- 					tip = { icon = "󰌶 " },
	-- 					important = { icon = "󰅾 " },
	-- 					warning = { icon = "󰀪 " },
	-- 					caution = { icon = "󰳦 " },
	-- 					info = { icon = "󰋽 " },
	-- 					success = { icon = "󰄬 " },
	-- 					danger = { icon = "󱐌 " },
	-- 					error = { icon = "󱐌 " },
	-- 					bug = { icon = "󰨰 " },
	-- 					quote = { icon = "󱆨 " },
	-- 					example = { icon = "󰉹 " },
	-- 				},
	-- 			},
	--
	-- 			anti_conceal = {
	-- 				enabled = true,
	-- 				ignore = {
	-- 					code_background = true,
	-- 					sign = true,
	-- 				},
	-- 			},
	-- 		})
	-- 	end,
	-- },

	{
		"keaising/im-select.nvim",
		event = "InsertEnter",
		config = function()
			require("im_select").setup({
				default_im_select = "keyboard-cn",
				set_im_select_commands = {
					Linux = "fcitx5-remote -s %s",
				},
				get_im_select_command = "fcitx5-remote -n | tr -d '\n'",
				get_im_select_timeout = 300,
			})
		end,
	},

	-- {
	--     "lervag/vimtex",
	--     lazy = false, -- we don't want to lazy load VimTeX
	--     -- tag = "v2.15", -- uncomment to pin to a specific release
	--     init = function()
	--         -- VimTeX configuration goes here, e.g.
	--         vim.g.vimtex_view_method = "sioyek"
	--         vim.g.vimtex_compiler_method = "latexmk"
	--         vim.g.vimtex_quickfix_mode = 0
	--     end,
	-- },
}
