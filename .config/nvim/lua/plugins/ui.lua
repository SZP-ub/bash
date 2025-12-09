---@diagnostic disable: undefined-global
return {

	-- 文件图标（供 lualine / 其他插件使用）
	{
		"nvim-tree/nvim-web-devicons",
		lazy = true,
		config = function()
			require("nvim-web-devicons").setup({
				override = {
					copilot = {
						icon = "",
						color = "#cba6f7", -- Catppuccin.mocha.mauve
						name = "Copilot",
					},
				},
				color_icons = true,
				default = true,
			})
		end,
	},

	-- 缩进线
	{
		"lukas-reineke/indent-blankline.nvim",
		event = "VeryLazy",
		config = function()
			local hooks = require("ibl.hooks")

			local highlight = {
				"RainbowRed",
				"RainbowYellow",
				"RainbowBlue",
				"RainbowOrange",
				"RainbowGreen",
				"RainbowViolet",
				"RainbowCyan",
			}

			-- 在 colorscheme 切换时设置高亮组
			hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
				vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
				vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
				vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
				vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
				vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
				vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
				vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })

				-- 活动/当前作用域高亮：纯黑、粗体并下划线（snacks.scope.underline 等价）
				-- 注意：终端对 bold/underline 支持不一，竖线字符可能看不明显
				vim.api.nvim_set_hl(0, "RainbowActive", { fg = "#000000", bold = true, underline = true })
			end)

			require("ibl").setup({
				indent = {
					highlight = highlight, -- 多色普通缩进线
					char = "│", -- 若终端看不出粗体，可换为 "┃"
				},
				scope = {
					enabled = true, -- 显示当前 scope
					show_start = true, -- 显示作用域开始处的缩进线
					highlight = { "RainbowActive" }, -- 使用上面定义的带下划线高亮
				},
				exclude = {
					filetypes = {
						"markdown",
						"help",
						"startify",
						"dashboard",
						"lazy",
						"neo-tree",
						"Trouble",
						"alpha",
						"snippets",
					},
				},
			})

			hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
		end,
	},

	-- 状态栏

	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		-- dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					theme = "gruvbox_light",
					icons_enabled = true,
					always_divide_middle = true,
					globalstatus = false,
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
					disabled_filetypes = {},
				},
				sections = {
					lualine_b = {
						function()
							if vim.fn.win_getid() == vim.fn.win_getid(vim.fn.winnr()) then
								return vim.fn.expand("%:t") .. (vim.bo.modified and " [+]" or "")
							end
							return ""
						end,
					},
					lualine_c = {},
					lualine_z = {
						function()
							local bufnr = vim.api.nvim_get_current_buf()
							local name = vim.fn.expand("%:t")
							return string.format(" %d %s", bufnr, name)
						end,
					},
					lualine_x = {},
					lualine_y = {},
				},
				inactive_sections = {
					lualine_b = {},
					lualine_c = {
						function()
							local win_width = vim.api.nvim_win_get_width(0)
							local content = "  " .. vim.fn.winnr()
							local pad = math.max(0, math.floor((win_width - #content) / 2))
							return string.rep(" ", pad) .. "%#MyBoldHL#" .. content
						end,
					},
					lualine_x = {},
					lualine_y = {},
					lualine_z = {
						function()
							local buftype = vim.api.nvim_buf_get_option(0, "filetype")
							if buftype == "NvimTree" or buftype == "tagbar" then
								return ""
							else
								local bufnr = vim.api.nvim_get_current_buf()
								local name = vim.fn.expand("%:t")
								local content = string.format(" %d %s", bufnr, name)
								return "%#MyBoldHL#" .. content
							end
						end,
					},
				},
				tabline = {
					lualine_a = {
						function()
							return "tabs"
						end,
					},
					lualine_b = {},
					lualine_c = {
						function()
							local tabs = {}
							for i = 1, vim.fn.tabpagenr("$") do
								local winnr = vim.fn.tabpagewinnr(i)
								local buflist = vim.fn.tabpagebuflist(i)
								local bufnr = buflist[winnr]
								local name = vim.fn.bufname(bufnr)
								name = name ~= "" and vim.fn.fnamemodify(name, ":t") or "[no name]"

								local modified = false
								for _, b in ipairs(buflist) do
									if vim.fn.getbufvar(b, "&modified") == 1 then
										modified = true
										break
									end
								end

								local current = (i == vim.fn.tabpagenr()) and "%#tablinesel#" or "%#tabline#"
								table.insert(
									tabs,
									string.format("%s %d %s%s ", current, i, name, modified and " [+]" or "")
								)
							end
							return table.concat(tabs)
						end,
					},
					lualine_x = {},
					lualine_y = {},
					lualine_z = {
						"buffers",
					},
				},
				extensions = {},
			})
			vim.api.nvim_create_autocmd("VimResized", {
				callback = function()
					vim.cmd("LualineUpdate")
				end,
			})
		end,
	},
}
