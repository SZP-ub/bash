---@diagnostic disable: undefined-global
return {

	{
		"nvim-treesitter/nvim-treesitter",
		event = "VeryLazy",
		build = ":TSUpdate",
		main = "nvim-treesitter.configs",
		opts = {
			auto_install = false,
			ensure_installed = {
				"cmake",
				"bash",
				"diff",
				"c",
				"cpp",
				"lua",
				"vim",
				"vimdoc",
				"query",
				"elixir",
				"heex",
				"javascript",
				"html",
				"json",
				"markdown",
			},
			sync_install = false,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			indent = { enable = true },
			rainbow = {
				enable = true,
				opts_extend = true,
				max_file_lines = 2000,
				colors = { "#68a0b0", "#946EaD", "#c7aA6D", "#9ccfd8", "#d2a8a8" },
			},
		},
		opts_extend = { "ensure_installed" },
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

	{
		"HiPhish/rainbow-delimiters.nvim",
		event = "VeryLazy",
		config = function()
			local ok, rainbow_delimiters = pcall(require, "rainbow-delimiters")
			if not ok then
				return
			end

			local highlights = {
				"RainbowDelimiterRed",
				"RainbowDelimiterYellow",
				"RainbowDelimiterBlue",
				"RainbowDelimiterOrange",
				"RainbowDelimiterGreen",
				"RainbowDelimiterViolet",
				"RainbowDelimiterCyan",
			}

			-- 主题优先链接 + 回退颜色（若主题没有对应组则使用 hex）
			local theme_map = {
				RainbowDelimiterRed = { "DiagnosticError", "#E06C75" },
				RainbowDelimiterYellow = { "WarningMsg", "#E5C07B" },
				RainbowDelimiterBlue = { "Type", "#61AFEF" },
				RainbowDelimiterOrange = { "Constant", "#D19A66" },
				RainbowDelimiterGreen = { "Identifier", "#98C379" },
				RainbowDelimiterViolet = { "Function", "#C678DD" },
				RainbowDelimiterCyan = { "Special", "#56B6C2" },
			}

			local function apply_theme_links()
				for group, pair in pairs(theme_map) do
					local target = pair[1]
					local hex = pair[2]
					if vim.fn.hlexists(target) == 1 then
						vim.api.nvim_set_hl(0, group, { link = target })
					else
						vim.api.nvim_set_hl(0, group, { fg = hex, nocombine = true })
					end
				end
			end

			-- 插件全局配置（可根据需要调整 blacklist 或其他字段）
			vim.g.rainbow_delimiters = {
				strategy = {
					[""] = rainbow_delimiters.strategy["global"],
					commonlisp = rainbow_delimiters.strategy["local"],
				},
				query = {
					[""] = "rainbow-delimiters",
					latex = "rainbow-blocks",
				},
				highlight = highlights,
			}

			-- 立刻应用一次链接（用于当前已加载主题）
			apply_theme_links()

			-- 当切换主题时重新应用（保持与主题同步）
			vim.api.nvim_create_autocmd("ColorScheme", {
				callback = function()
					apply_theme_links()
				end,
			})
		end,
	},

	{
		"sustech-data/wildfire.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		keys = {
			{ "<CR>", mode = { "n", "x" }, desc = "wildfire 区块选择/扩展" },
			{ "<BS>", mode = { "n", "x" }, desc = "wildfire 区块收缩" },
		},
		config = function()
			require("wildfire").setup({
				surrounds = {
					{ "(", ")" },
					{ "{", "}" },
					{ "<", ">" },
					{ "[", "]" },
					{ "`", "`" },
					{ '"', '"' },
					{ "'", "'" },
				},
				keymaps = {
					init_selection = "<CR>",
					node_incremental = "<CR>",
					node_decremental = "<BS>",
				},
				filetype_exclude = { "qf" },
			})
		end,
	},
}
