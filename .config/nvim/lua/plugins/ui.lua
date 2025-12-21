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
		enabled = vim.g.have_nerd_font,
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

	-- {
	-- 	"nvim-lualine/lualine.nvim",
	-- 	event = "VeryLazy",
	-- 	dependencies = { "nvim-tree/nvim-web-devicons" },
	-- 	config = function()
	-- 		local ok_devicons, devicons = pcall(require, "nvim-web-devicons")
	--
	-- 		local colors = {
	-- 			a_bg = "#ebdbb2",
	-- 			a_fg = "#282828",
	-- 			inactive_a_bg = "#83a598",
	-- 			inactive_a_fg = "#fbf1c7",
	-- 			z_bg = "#7c6f64",
	-- 			z_fg = "#ffffff",
	-- 			progress_bg = "#d5c4a1",
	-- 			progress_fg = "#1c1f24",
	-- 			diag_inactive_bg = "#3c3836",
	-- 			diag_inactive_fg = "#ebdbb2",
	-- 			inactive_b_bg = "#b3b3b3",
	-- 			inactive_b_fg = "#fbf1c7",
	-- 			tabline_c_bg = "#b3b3b3",
	-- 			tabline_c_fg = "#282828",
	-- 			inactive_c_space_fg = "#ebdbb2",
	-- 		}
	--
	-- 		local function rgb_to_hex(n)
	-- 			if not n then
	-- 				return nil
	-- 			end
	-- 			return string.format("#%06x", n)
	-- 		end
	--
	-- 		local function ensure_devicon_bg(group)
	-- 			if not group or group == "" then
	-- 				return
	-- 			end
	-- 			local ok, hl = pcall(vim.api.nvim_get_hl_by_name, group, true)
	-- 			local fg_hex = nil
	-- 			if ok and hl then
	-- 				local fg = hl.foreground or hl.fg
	-- 				if fg then
	-- 					fg_hex = rgb_to_hex(fg)
	-- 				end
	-- 			end
	-- 			if not fg_hex then
	-- 				fg_hex = colors.z_fg
	-- 			end
	-- 			vim.api.nvim_set_hl(0, group, { fg = fg_hex, bg = colors.z_bg })
	-- 		end
	--
	-- 		local function apply_custom_hl()
	-- 			vim.api.nvim_set_hl(0, "MyLualineZ", { bg = colors.z_bg, fg = colors.z_fg, bold = false })
	-- 			vim.api.nvim_set_hl(0, "MyBoldHL", { bg = colors.z_bg, fg = colors.z_fg, bold = true })
	-- 			vim.api.nvim_set_hl(
	-- 				0,
	-- 				"DiagInactive",
	-- 				{ bg = colors.diag_inactive_bg, fg = colors.diag_inactive_fg, bold = false }
	-- 			)
	-- 			vim.api.nvim_set_hl(
	-- 				0,
	-- 				"ProgressInactive",
	-- 				{ bg = colors.progress_bg, fg = colors.progress_fg, bold = false }
	-- 			)
	-- 			vim.api.nvim_set_hl(
	-- 				0,
	-- 				"InactiveB",
	-- 				{ bg = colors.inactive_b_bg, fg = colors.inactive_b_fg, bold = false }
	-- 			)
	--
	-- 			-- 非活动 c 的主体高亮（背景与 InactiveB 不同）
	-- 			vim.api.nvim_set_hl(0, "InactiveC", { bg = colors.z_bg, fg = colors.z_fg, bold = false })
	-- 			-- 空白使用独立高亮（与 InactiveB 区分开）
	-- 			vim.api.nvim_set_hl(0, "InactiveCSpace", { bg = "NONE", fg = colors.inactive_c_space_fg, bold = false })
	--
	-- 			vim.api.nvim_set_hl(0, "TablineC", { bg = colors.tabline_c_bg, fg = colors.tabline_c_fg, bold = false })
	-- 			vim.api.nvim_set_hl(
	-- 				0,
	-- 				"TablineCsel",
	-- 				{ bg = colors.tabline_c_bg, fg = colors.tabline_c_fg, bold = true }
	-- 			)
	-- 		end
	--
	-- 		apply_custom_hl()
	-- 		vim.api.nvim_create_autocmd("ColorScheme", {
	-- 			callback = function()
	-- 				apply_custom_hl()
	-- 				pcall(vim.cmd, "LualineUpdate")
	-- 			end,
	-- 		})
	--
	-- 		local mode = {
	-- 			"mode",
	-- 			fmt = function(str)
	-- 				return " " .. str
	-- 			end,
	-- 			padding = { left = 1, right = 1 },
	-- 		}
	--
	-- 		local hide_in_width = function()
	-- 			return vim.fn.winwidth(0) > 100
	-- 		end
	--
	-- 		local diagnostics = {
	-- 			"diagnostics",
	-- 			sources = { "nvim_diagnostic" },
	-- 			sections = { "error", "warn" },
	-- 			symbols = { error = " ", warn = " ", info = " ", hint = " " },
	-- 			colored = false,
	-- 			update_in_insert = false,
	-- 			always_visible = false,
	-- 			cond = hide_in_width,
	-- 		}
	--
	-- 		local diff = {
	-- 			"diff",
	-- 			colored = false,
	-- 			symbols = { added = " ", modified = " ", removed = " " },
	-- 			cond = hide_in_width,
	-- 		}
	--
	-- 		local current_buf_display = function()
	-- 			local bufnr = vim.api.nvim_get_current_buf()
	-- 			local name = vim.fn.expand("%:t")
	-- 			local icon = ""
	-- 			local icon_hl = nil
	-- 			if ok_devicons then
	-- 				local filename_full = vim.fn.expand("%:t")
	-- 				local extension = vim.fn.expand("%:e")
	-- 				local ok_get, got_icon, got_hl = pcall(function()
	-- 					return devicons.get_icon(filename_full, extension, { default = true })
	-- 				end)
	-- 				if ok_get and got_icon and got_icon ~= "" then
	-- 					icon = got_icon
	-- 				end
	-- 				if ok_get and got_hl and type(got_hl) == "string" and got_hl ~= "" then
	-- 					icon_hl = got_hl
	-- 					pcall(ensure_devicon_bg, icon_hl)
	-- 				end
	-- 			end
	-- 			local display_name = name == "" and "[no name]" or name
	-- 			if icon_hl then
	-- 				return string.format("%%#%s#%s%%*%%#MyLualineZ# %d %s%%*", icon_hl, icon, bufnr, display_name)
	-- 			else
	-- 				return string.format("%%#MyLualineZ#%s %d %s%%*", icon, bufnr, display_name)
	-- 			end
	-- 		end
	--
	-- 		local mode_inactive = {
	-- 			"mode",
	-- 			fmt = mode.fmt,
	-- 			color = { fg = colors.inactive_a_fg, bg = colors.inactive_a_bg },
	-- 			padding = { left = 1, right = 1 },
	-- 		}
	--
	-- 		-- 关键改动：diagnostics_inactive_fn 在结尾切换到 InactiveCSpace 并添加一个空格
	-- 		local diagnostics_inactive_fn = function()
	-- 			local errs = #vim.diagnostic.get(
	-- 				0,
	-- 				{ severity = { min = vim.diagnostic.severity.ERROR, max = vim.diagnostic.severity.ERROR } }
	-- 			)
	-- 			local warns = #vim.diagnostic.get(
	-- 				0,
	-- 				{ severity = { min = vim.diagnostic.severity.WARN, max = vim.diagnostic.severity.WARN } }
	-- 			)
	-- 			local out = ""
	-- 			if errs > 0 then
	-- 				out = out .. " " .. errs .. " "
	-- 			end
	-- 			if warns > 0 then
	-- 				out = out .. " " .. warns .. " "
	-- 			end
	-- 			if out == "" then
	-- 				-- 即使没有 diagnostics，也输出一个使用 InactiveCSpace 的空格以切断 InactiveB 背景
	-- 				return "%#InactiveCSpace# %*"
	-- 			end
	-- 			-- 先用 InactiveB 显示内容，然后立即切换到 InactiveCSpace 并输出一个空格（切断背景）
	-- 			return "%#InactiveB#" .. vim.trim(out) .. "%*%#InactiveCSpace# %*"
	-- 		end
	--
	-- 		local function get_git_branch()
	-- 			local branch = vim.b.gitsigns_head
	-- 			if branch and branch ~= "" then
	-- 				return branch
	-- 			end
	-- 			branch = vim.b.fugitive_head or vim.b["fugitive_head"]
	-- 			if branch and branch ~= "" then
	-- 				return branch
	-- 			end
	-- 			branch = vim.g.gitsigns_head
	-- 			if branch and branch ~= "" then
	-- 				return branch
	-- 			end
	--
	-- 			local filepath = vim.fn.expand("%:p")
	-- 			if filepath == "" then
	-- 				return ""
	-- 			end
	-- 			local dir = vim.fn.fnamemodify(filepath, ":h")
	-- 			local git_dir = vim.fn.finddir(".git", dir .. ";")
	-- 			if git_dir == "" then
	-- 				return ""
	-- 			end
	-- 			local repo_root = vim.fn.fnamemodify(git_dir, ":h")
	--
	-- 			local ok, result =
	-- 				pcall(vim.fn.systemlist, { "git", "-C", repo_root, "rev-parse", "--abbrev-ref", "HEAD" })
	-- 			if ok and result and type(result) == "table" and #result > 0 and result[1] and result[1] ~= "" then
	-- 				if result[1] ~= "HEAD" and vim.v.shell_error == 0 then
	-- 					return result[1]
	-- 				end
	-- 				if result[1] == "HEAD" then
	-- 					local ok2, r2 =
	-- 						pcall(vim.fn.systemlist, { "git", "-C", repo_root, "rev-parse", "--short", "HEAD" })
	-- 					if
	-- 						ok2
	-- 						and r2
	-- 						and type(r2) == "table"
	-- 						and #r2 > 0
	-- 						and r2[1]
	-- 						and r2[1] ~= ""
	-- 						and vim.v.shell_error == 0
	-- 					then
	-- 						return r2[1]
	-- 					end
	-- 				end
	-- 			end
	-- 			return ""
	-- 		end
	--
	-- 		local branch_component = function()
	-- 			local branch = get_git_branch()
	-- 			if branch and branch ~= "" then
	-- 				return " " .. branch
	-- 			end
	-- 			return ""
	-- 		end
	--
	-- 		local inactive_z_pct_fn = function()
	-- 			local current_line = vim.fn.line(".")
	-- 			local total_lines = vim.fn.line("$")
	-- 			local pct = 0
	-- 			if total_lines > 0 then
	-- 				pct = math.floor((current_line / total_lines) * 100)
	-- 			end
	-- 			local s = string.format("%d%%%%", pct)
	-- 			return "%#ProgressInactive#" .. s .. "%*"
	-- 		end
	--
	-- 		local inactive_z_buf_fn = function()
	-- 			local buftype = vim.api.nvim_buf_get_option(0, "filetype")
	-- 			if buftype == "NvimTree" or buftype == "tagbar" then
	-- 				return ""
	-- 			end
	-- 			local bufnr = vim.api.nvim_get_current_buf()
	-- 			local name = vim.fn.expand("%:t")
	-- 			local icon = ""
	-- 			local icon_hl = nil
	-- 			if ok_devicons then
	-- 				local ok_get, got_icon, got_hl = pcall(function()
	-- 					return devicons.get_icon(name, vim.fn.expand("%:e"), { default = true })
	-- 				end)
	-- 				if ok_get and got_icon and got_icon ~= "" then
	-- 					icon = got_icon
	-- 				end
	-- 				if ok_get and got_hl and got_hl ~= "" then
	-- 					icon_hl = got_hl
	-- 					pcall(ensure_devicon_bg, icon_hl)
	-- 				end
	-- 			end
	-- 			local content = string.format("%s %d %s", icon, bufnr, name)
	-- 			if icon_hl then
	-- 				return string.format("%%#%s#%s%%*%%#MyBoldHL# %d %s%%*", icon_hl, icon, bufnr, name)
	-- 			else
	-- 				return "%#MyBoldHL#" .. content .. "%*"
	-- 			end
	-- 		end
	--
	-- 		local function strip_highlight_spec(s)
	-- 			if not s or s == "" then
	-- 				return ""
	-- 			end
	-- 			local t = s
	-- 			t = t:gsub("%%#.-#", "")
	-- 			t = t:gsub("%%*", "")
	-- 			return t
	-- 		end
	--
	-- 		local mode_name_map = {
	-- 			n = "NORMAL",
	-- 			no = "N·OP",
	-- 			i = "INSERT",
	-- 			ic = "INSERT",
	-- 			t = "TERMINAL",
	-- 			v = "VISUAL",
	-- 			V = "V-LINE",
	-- 			[""] = "V-BLOCK",
	-- 			c = "COMMAND",
	-- 			s = "SELECT",
	-- 			R = "REPLACE",
	-- 			Rv = "V-REPLACE",
	-- 			["!"] = "SHELL",
	-- 		}
	-- 		local function get_mode_name()
	-- 			local m = vim.api.nvim_get_mode().mode
	-- 			return mode_name_map[m] or m
	-- 		end
	--
	-- 		-- 居中：pad 使用 InactiveCSpace（与 InactiveB 不同），content 使用 InactiveC
	-- 		local inactive_c_center = function()
	-- 			local idx = vim.fn.winnr()
	-- 			local content = string.format("   %d", idx)
	-- 			local content_len = vim.fn.strdisplaywidth(content)
	--
	-- 			local left_mode = " " .. get_mode_name()
	-- 			local left_diag = diagnostics_inactive_fn() -- 已在末尾切换到 InactiveCSpace 并输出一个空格
	-- 			local left_combined = left_mode .. " " .. strip_highlight_spec(left_diag)
	-- 			local left_len = vim.fn.strdisplaywidth(left_combined)
	--
	-- 			local right_combined = strip_highlight_spec(inactive_z_buf_fn())
	-- 				.. " "
	-- 				.. strip_highlight_spec(inactive_z_pct_fn())
	-- 			local right_len = vim.fn.strdisplaywidth(right_combined)
	--
	-- 			local winw = vim.fn.winwidth(0)
	-- 			local target_left_total = math.floor((winw - content_len) / 2)
	-- 			local needed_pad = target_left_total - left_len
	-- 			if needed_pad < 0 then
	-- 				needed_pad = 0
	-- 			end
	--
	-- 			local pad = string.rep(" ", needed_pad)
	--
	-- 			-- pad 与 diagnostics 尾部（那个单个空格）一起形成连续的 InactiveCSpace 区域
	-- 			return "%#InactiveCSpace#" .. pad .. "%*%#InactiveC#" .. content .. "%*"
	-- 		end
	--
	-- 		local tabline_c_highlight = function()
	-- 			local tabs = {}
	-- 			local cur = vim.fn.tabpagenr()
	-- 			for i = 1, vim.fn.tabpagenr("$") do
	-- 				local winnr = vim.fn.tabpagewinnr(i)
	-- 				local buflist = vim.fn.tabpagebuflist(i)
	-- 				local bufnr = buflist[winnr]
	-- 				local name = vim.fn.bufname(bufnr)
	-- 				name = name ~= "" and vim.fn.fnamemodify(name, ":t") or "[no name]"
	-- 				local modified = false
	-- 				for _, b in ipairs(buflist) do
	-- 					if vim.fn.getbufvar(b, "&modified") == 1 then
	-- 						modified = true
	-- 						break
	-- 					end
	-- 				end
	-- 				local label = string.format(" %d %s%s ", i, name, modified and " [+]" or "")
	-- 				if i == cur then
	-- 					table.insert(tabs, "%#TablineCsel#" .. label .. "%*")
	-- 				else
	-- 					table.insert(tabs, "%#TablineC#" .. label .. "%*")
	-- 				end
	-- 			end
	-- 			return table.concat(tabs)
	-- 		end
	--
	-- 		require("lualine").setup({
	-- 			options = {
	-- 				icons_enabled = true,
	-- 				theme = "gruvbox_light",
	-- 				section_separators = { left = "", right = "" },
	-- 				component_separators = { left = "", right = "" },
	-- 				disabled_filetypes = { "alpha", "neo-tree" },
	-- 				always_divide_middle = true,
	-- 				globalstatus = false,
	-- 			},
	-- 			sections = {
	-- 				lualine_a = { mode },
	-- 				lualine_b = {
	-- 					branch_component,
	-- 					function()
	-- 						return vim.fn.expand("%:t") .. (vim.bo.modified and " [+]" or "")
	-- 					end,
	-- 				},
	-- 				lualine_c = {},
	-- 				lualine_x = { diagnostics, diff, { "encoding", cond = hide_in_width } },
	-- 				lualine_y = { { "location", cond = hide_in_width }, "progress" },
	-- 				lualine_z = { { current_buf_display } },
	-- 			},
	--
	-- 			inactive_sections = {
	-- 				lualine_a = { mode_inactive },
	-- 				lualine_b = { diagnostics_inactive_fn },
	-- 				lualine_c = { inactive_c_center },
	-- 				lualine_x = {},
	-- 				lualine_y = {},
	-- 				lualine_z = { inactive_z_pct_fn, inactive_z_buf_fn },
	-- 			},
	--
	-- 			tabline = {
	-- 				lualine_a = {
	-- 					function()
	-- 						return "tabs"
	-- 					end,
	-- 				},
	-- 				lualine_b = {},
	-- 				lualine_c = { tabline_c_highlight },
	-- 				lualine_x = {},
	-- 				lualine_y = {},
	-- 				lualine_z = { "buffers" },
	-- 			},
	-- 			extensions = { "fugitive" },
	-- 		})
	--
	-- 		vim.api.nvim_create_autocmd("VimResized", {
	-- 			callback = function()
	-- 				vim.cmd("LualineUpdate")
	-- 			end,
	-- 		})
	-- 		vim.api.nvim_create_user_command("ApplyLualineIconBg", function()
	-- 			apply_custom_hl()
	-- 			vim.cmd("LualineUpdate")
	-- 		end, {})
	-- 	end,
	-- },
}
