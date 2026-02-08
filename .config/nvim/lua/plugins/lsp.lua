-- 小工具：安全 require（统一封装 pcall(require, ...)）
-- 返回模块或 nil（失败时不抛错）
local function safe_require(name)
	local ok, mod = pcall(require, name)
	if ok then
		return mod
	end
	return nil
end

return {
	---------------------------------------------------------------------------
	-- 1. mason.nvim：负责二进制工具安装（LSP servers / DAP / formatters / linters）
	--    说明：
	--      - mason 只负责把工具下载并管理到本机（例如 clangd、pyright、lua-language-server 等）。
	--      - 不直接负责“启动” LSP 客户端，启动由 Neovim 内置 lsp 或其他桥接插件负责。
	--      - 这里设置了 UI 大小与图标，方便使用 :Mason 时查看安装状态。
	---------------------------------------------------------------------------
	{
		"mason-org/mason.nvim",
		-- 延迟加载：VeryLazy（避免启动时阻塞），可根据个人习惯调整为 BufReadPre/BufNewFile 等
		event = "VeryLazy",
		opts = {
			ui = {
				-- Mason UI 宽高（相对于编辑器），可按需调小以避免遮挡
				width = 0.8,
				height = 0.7,
				-- Mason 列表状态图标（已安装 / 安装中 / 未安装）
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
		config = function(_, opts)
			-- 安全加载 mason，若未安装则通知并跳过配置
			local mason = safe_require("mason")
			if not mason then
				vim.notify("mason.nvim 未找到，跳过 mason 配置", vim.log.levels.WARN)
				return
			end
			-- 调用 mason.setup 应用上面的 opts
			mason.setup(opts)
		end,
	},

	---------------------------------------------------------------------------
	-- 2. mason-lspconfig.nvim：把 mason 与 nvim-lspconfig 连接起来
	--    说明：
	--      - 自动安装 ensure_installed 列表里的 server（mason 负责下载）
	--      - 提供 automatic_installation：在配置时需要某 server 但本地未安装时自动安装（按需）
	---------------------------------------------------------------------------
	{
		"mason-org/mason-lspconfig.nvim",
		event = "VeryLazy",
		dependencies = { "mason-org/mason.nvim" },
		opts = {
			-- 列表里的名字与 nvim-lspconfig / mason registry 的名字相同
			ensure_installed = { "clangd", "lua_ls", "marksman", "pyright", "jsonls", "texlab" },
			automatic_installation = true,
		},
		config = function(_, opts)
			-- 1) 安全加载 mason-lspconfig
			local mason_lspconfig = safe_require("mason-lspconfig")
			if not mason_lspconfig then
				vim.notify("mason-lspconfig.nvim 未找到，跳过 LSP 安装桥接配置", vim.log.levels.WARN)
				return
			end

			-- 2) 提前创建 capabilities（并注入 cmp_nvim_lsp 的能力）
			--    这样能保证后续对单个 server 的配置能使用到 same capabilities（避免时序问题）
			local base_capabilities = vim.lsp.protocol.make_client_capabilities()
			local cmp_nvim_lsp = safe_require("cmp_nvim_lsp")
			local capabilities = base_capabilities
			if cmp_nvim_lsp then
				-- default_capabilities 会把 snippet 等能力加入 capabilities
				capabilities = cmp_nvim_lsp.default_capabilities(base_capabilities)
			end

			-- 3) 全局默认配置（对所有 server生效的默认值）
			--    使用 vim.lsp.config("*", {...}) 来设置全局默认 capabilities 与 flags
			--    flags.debounce_text_changes 控制 textDocument/didChange 的防抖时间，单位 ms
			vim.lsp.config("*", {
				capabilities = capabilities,
				flags = {
					debounce_text_changes = 150, -- 更低的值更实时但更耗 CPU，按需调整
				},
			})

			-- 4) 初始化 mason-lspconfig（安装器本体）
			mason_lspconfig.setup(opts)

			-------------------------------------------------------------------
			-- 5) LspAttach：为 attach 到 buffer 的 LSP 客户端设置 buffer-local 的键映射与 autocmd
			--    说明：
			--      - LspAttach 在每次 LSP client attach buffer 时触发，可以安全地创建 buffer-local 映射
			--      - 把 keymap 限制在 buffer 上，避免全局键位冲突，并便于不同语言定制不同快捷键
			-------------------------------------------------------------------
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("user-lsp-attach", { clear = true }),
				callback = function(event)
					local buf = event.buf
					-- 获取触发本次 attach 的 client（注意有时 client 可能为 nil）
					local client = vim.lsp.get_client_by_id(event.data.client_id)

					-- 简化的 buffer-local 映射函数
					local function map(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, {
							buffer = buf,
							desc = "LSP: " .. (desc or keys),
							silent = true,
						})
					end

					-- 常用 LSP 快捷键（建议保留或按需改动）
					map("gd", vim.lsp.buf.definition, "Goto Definition")
					map("gi", vim.lsp.buf.implementation, "Goto Implementation")
					map("grt", vim.lsp.buf.type_definition, "Type Definition")
					map("grn", vim.lsp.buf.rename, "Rename")
					map("gra", vim.lsp.buf.code_action, "Code Action", { "n", "x" })
					map("grd", vim.lsp.buf.declaration, "Goto Declaration")
					map("[g", vim.diagnostic.goto_prev, "Previous Diagnostic")
					map("]g", vim.diagnostic.goto_next, "Next Diagnostic")

					-- K：优先尝试 ufo.peekFoldedLinesUnderCursor（用于折叠 peek），失败时回退到 LSP hover
					-- 使用 pcall + safe_require 来保证无论 ufo 是否安装都不会报错
					map("K", function()
						local ufo = safe_require("ufo")
						if ufo then
							local ok, winid = pcall(ufo.peekFoldedLinesUnderCursor)
							if ok and winid and winid ~= 0 then
								-- 已成功打开 peek 窗口，直接返回
								return
							end
						end
						-- 回退到 LSP hover（用 pcall 以防个别 LSP 实现导致错误）
						pcall(vim.lsp.buf.hover)
					end, "Peek fold or show hover")

					-- documentHighlight：当 LSP 支持且文件不是超大文件时启用
					local function client_supports(method)
						return client and client.supports_method and client:supports_method(method, buf)
					end

					-- 判断是否为“大文件”，以避免 documentHighlight 在巨文件上造成性能问题
					local is_big_file = false
					do
						-- 尝试获取 buffer 对应的文件尺寸（如果 buffer 未关联文件或读取 stat 失败则忽略）
						local ok_name, fname = pcall(vim.api.nvim_buf_get_name, buf)
						if ok_name and fname and fname ~= "" then
							local stat_ok, stat = pcall(vim.loop.fs_stat, fname)
							if stat_ok and stat and stat.size and stat.size > 1024 * 1024 then
								-- > 1MB 视为大文件（可根据需要调整阈值）
								is_big_file = true
							end
						end
					end

					if client_supports(vim.lsp.protocol.Methods.textDocument_documentHighlight) and not is_big_file then
						-- 使用单独的 augroup 管理高亮相关 autocmd，方便 detach/clear
						local highlight_grp =
							vim.api.nvim_create_augroup("user-lsp-document-highlight", { clear = false })

						-- 当光标停下（CursorHold / CursorHoldI）时请求 document_highlight
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = buf,
							group = highlight_grp,
							callback = vim.lsp.buf.document_highlight,
						})

						-- 光标移动时清除 references
						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = buf,
							group = highlight_grp,
							callback = vim.lsp.buf.clear_references,
						})

						-- LspDetach 时清理相关 autocmd（仅清理当前 buffer 的）
						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("user-lsp-detach", { clear = true }),
							callback = function(ev)
								if ev.buf == buf then
									vim.lsp.buf.clear_references()
									vim.api.nvim_clear_autocmds({
										group = "user-lsp-document-highlight",
										buffer = ev.buf,
									})
								end
							end,
						})
					end

					-- Inlay Hints（Neovim 0.11+）：如果 LSP 支持则自动为当前 buffer 打开
					if client_supports(vim.lsp.protocol.Methods.textDocument_inlayHint) then
						pcall(vim.lsp.inlay_hint.enable, true, { bufnr = buf })
					end
				end,
			})

			-------------------------------------------------------------------
			-- 6) 全局诊断（vim.diagnostic）配置
			--    说明：
			--      - severity_sort: 按严重程度排序，能把 ERROR 放在更显眼位置
			--      - float.source = "if_many": 仅在来源较多时显示来源（简洁）
			--      - underline: 只对 ERROR 下划线，减少视觉噪声
			--      - virtual_text: 仅显示消息主体，spacing 控制间距
			-------------------------------------------------------------------
			vim.diagnostic.config({
				severity_sort = true,
				float = { source = "if_many" },
				underline = { severity = vim.diagnostic.severity.ERROR },
				signs = {
					-- signcolumn 使用 text 字段显示对应符号，便于配色与对齐
					text = {
						[vim.diagnostic.severity.ERROR] = " ",
						[vim.diagnostic.severity.WARN] = " ",
						[vim.diagnostic.severity.INFO] = " ",
						[vim.diagnostic.severity.HINT] = "",
					},
				},
				virtual_text = {
					source = "if_many",
					spacing = 2,
					format = function(diagnostic)
						-- 只显示诊断消息主体，省去 code / source 等冗余信息
						return diagnostic.message
					end,
				},
				update_in_insert = true, -- 在插入模式也更新诊断（权衡：更及时但可能影响输入）
			})

			-- Hover 使用圆角边框（美观）
			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })

			-------------------------------------------------------------------
			-- 7) 为特定 LSP server 提供精细化配置（可按需添加 / 修改）
			--    说明：
			--      - 使用 vim.lsp.config("server_name", { ... }) 为某个 server 增加或覆盖配置
			--      - root_dir 使用 vim.fs.root(0, markers) 根据当前 buffer 向上查找标记文件以推断项目根
			-------------------------------------------------------------------
			local function root_with(markers)
				-- 传入标记文件列表（例如 .git、package.json 等），返回合适的 root_dir
				return vim.fs.root(0, markers)
			end

			-- clangd（C/C++/ObjC/CUDA）：增强 completion 行为并协商 offsetEncoding
			vim.lsp.config("clangd", {
				name = "clangd",
				cmd = { "clangd" },
				filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
				root_dir = root_with({
					".clangd",
					".clang-tidy",
					".clang-format",
					"compile_commands.json",
					"compile_flags.txt",
					"configure.ac",
					".git",
				}),
				capabilities = vim.tbl_deep_extend("force", capabilities, {
					textDocument = { completion = { editsNearCursor = true } },
					offsetEncoding = { "utf-8", "utf-16" },
				}),
				-- on_init：当 clangd 返回 offsetEncoding 时，写回 client，保持位置计算一致
				on_init = function(client, init_result)
					if init_result and init_result.offsetEncoding then
						client.offset_encoding = init_result.offsetEncoding
					end
				end,
			})

			-- lua-language-server（Lua）：尽量使用 PATH 上的可执行文件，未安装则通知
			local lua_ls_cmd = { "lua-language-server" }
			-- 可选：如果你在非标准路径安装 lua-language-server，请把下面注释的 fallback 路径取消并修改为你的路径
			-- local fallback_ls = "/home/i/tools/lua-language-server-3.16.1-linux-x64/bin/lua-language-server"
			-- if vim.fn.executable("lua-language-server") == 0 then
			--     lua_ls_cmd = { fallback_ls }
			-- end
			if vim.fn.executable("lua-language-server") == 0 then
				-- 这里只做提示，不强制替换命令，让用户在容器或 CI 环境自行处理
				vim.notify(
					"系统 PATH 中未找到 lua-language-server，请确保已安装或修改配置中的 fallback 路径",
					vim.log.levels.INFO
				)
			end

			vim.lsp.config("lua_ls", {
				name = "lua_ls",
				cmd = lua_ls_cmd,
				filetypes = { "lua" },
				root_dir = root_with({ ".luarc.json", ".luarc.jsonc", ".git" }),
				settings = {
					Lua = {
						workspace = { checkThirdParty = false }, -- 不自动弹出第三方库提示
						hint = { enable = true }, -- 开启内联提示（需配合 inlay hints）
						diagnostics = { globals = { "vim" } }, -- 避免在 Neovim 配置中提示 vim 未定义
						-- format = { enable = true },
					},
				},
			})

			-- marksman（Markdown）
			vim.lsp.config("marksman", {
				name = "marksman",
				cmd = { "marksman", "server" },
				filetypes = { "markdown", "markdown.mdx" },
				root_dir = root_with({ ".git" }),
			})

			-- pyright（Python）
			vim.lsp.config("pyright", {
				name = "pyright",
				cmd = { "pyright-langserver", "--stdio" },
				filetypes = { "python" },
				root_dir = root_with({
					"pyrightconfig.json",
					"pyproject.toml",
					"setup.py",
					"setup.cfg",
					"requirements.txt",
					"Pipfile",
					".git",
				}),
			})

			-- jsonls（JSON/JSONC）
			vim.lsp.config("jsonls", {
				name = "jsonls",
				cmd = { "vscode-json-language-server", "--stdio" },
				filetypes = { "json", "jsonc" },
				root_dir = root_with({ "package.json", "tsconfig.json", ".git" }),
				settings = {
					json = { validate = { enable = true } },
				},
			})

			-- texlab（LaTeX）
			-- vim.lsp.config("texlab", {
			-- 	name = "texlab",
			-- 	cmd = { "texlab" }, -- 若 texlab 不在 PATH，改为绝对路径，例如 "/usr/local/bin/texlab"
			-- 	filetypes = { "tex", "bib" },
			-- 	-- 根目录检测：常见的 latex 项目标识文件
			-- 	root_dir = root_with({ ".latexmkrc", "latexmkrc", "texlab.json", ".git" }),
			-- 	-- 保持与其它 server 一致的 capabilities（例如 completion 等）
			-- 	capabilities = vim.tbl_deep_extend("force", capabilities, {}),
			-- 	settings = {
			-- 		texlab = {
			-- 			-- build 配置：默认使用 latexmk，打开 synctex，使用 xelatex（如需 pdflatex 改参数）
			-- 			build = {
			-- 				executable = "latexmk", -- 若 latexmk 不在 PATH，请填写绝对路径
			-- 				args = { "-xelatex", "-file-line-error", "-synctex=1", "-interaction=nonstopmode", "%f" },
			-- 				onSave = true, -- 保存时自动构建；若不需要自��构建改为 false
			-- 				forwardSearchAfter = true, -- 构建后尝试触发 forward search
			-- 			},
			-- 			-- forwardSearch：与查看器配合（示例为 Sioyek）
			-- 			forwardSearch = {
			-- 				executable = "sioyek", -- 若使用其它查看器（zathura/okular），改为相应命令并调整 args
			-- 				args = { "--forward-search-file", "%f", "--forward-search-line", "%l", "%p" },
			-- 			},
			-- 			-- chktex（行级 lint）与其它 lint/format 选项
			-- 			chktex = { onOpen = false, onEdit = false, onSave = true, onType = false },
			-- 			lint = { onChange = false }, -- 关闭实时 lint（按需开启）
			-- 			-- formatting / latexindent：如果系统安装了 latexindent，可启用格式化
			-- 			-- 注意：不同版本 texlab 对字段名略有差异，这里给出常见组合
			-- 			formatter = {
			-- 				latexindent = {
			-- 					modifyLineBreaks = true,
			-- 				},
			-- 			},
			-- 			latexindent = {
			-- 				-- 如果你在特定路径安装 latexindent，请写明 path 字段
			-- 				-- path = "/usr/bin/latexindent",
			-- 				modifyLineBreaks = true,
			-- 			},
			-- 			-- 若需要把中间文件放到一个 aux 目录（避免污染源码目录），可以启用下面字段并配合 latexmkrc
			-- 			-- auxDirectory = "aux", -- 需要在 latexmkrc / 编译参数中一并配置
			-- 		},
			-- 	},
			-- })

			-------------------------------------------------------------------
			-- 8) 启用列出的 server（会在对应 filetype 打开时自动 attach）
			--    说明：
			--      - vim.lsp.enable 会确保当缓冲区的 filetype 匹配时自动尝试启动这些 server。
			--      - 确保这些 server 的可执行文件已经通过 mason 或手动安装到系统中，或 PATH 可达。
			-------------------------------------------------------------------
			vim.lsp.enable({ "clangd", "lua_ls", "marksman", "pyright", "jsonls", "texlab" })
		end,
	},

	---------------------------------------------------------------------------
	-- 3. nvim-cmp：插入模式补全（LSP / snippet / buffer / path 等）
	--    说明：
	--      - 本配置只接管插入模式的补全，命令行补全交由 wilder.nvim（或其他）处理，避免冲突。
	--      - 使用 LuaSnip 作为 snippet 引擎并尝试加载 SnipMate 风格的 snippets（位于 ~/.config/nvim/snippets）
	---------------------------------------------------------------------------
	{
		"hrsh7th/nvim-cmp",
		event = "VeryLazy",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp", -- LSP source
			"saadparwaiz1/cmp_luasnip", -- luasnip source
			"hrsh7th/cmp-buffer", -- buffer source
			"hrsh7th/cmp-path", -- path source
			{ "L3MON4D3/LuaSnip", version = "v2.*" }, -- snippet engine
			"lukas-reineke/cmp-rg",
			{ "kdheepak/cmp-latex-symbols", ft = { "latex", "markdown", "markdown_inline" } },
			{ "micangl/cmp-vimtex", ft = { "latex", "markdown", "markdown_inline" } },
			{ "hrsh7th/cmp-omni", ft = { "tex" } },
			"rasulomaroff/cmp-bufname",
			-- "ray-x/cmp-treesitter",

			-- "delphinus/cmp-ctags",
			-- "f3fora/cmp-spell", -- spell source
			-- "onsails/lspkind-nvim", -- 可选：图标支持
			-- "octaltree/cmp-look", -- look source（英语词库）
		},
		config = function()
			local cmp = safe_require("cmp")
			if not cmp then
				vim.notify("nvim-cmp 未找到，跳过补全配置", vim.log.levels.WARN)
				return
			end
			local luasnip = safe_require("luasnip")
			if not luasnip then
				vim.notify("LuaSnip 未找到，跳过 snippet 功能", vim.log.levels.WARN)
			end

			-- 若 LuaSnip 可用，尝试按需加载 SnipMate 风格 snippets（用户可在 config/snippets 放置自定义片段）
			if luasnip then
				pcall(require("luasnip.loaders.from_snipmate").lazy_load, {
					paths = { vim.fn.stdpath("config") .. "/snippets" },
				})
			end

			-- 智能跳出配对或退化为 Tab（用于 Tab 键在不同上下文下的智能行为）
			local function jump_out_pair_forward_or_tab()
				local row, col = unpack(vim.api.nvim_win_get_cursor(0))
				local line = vim.api.nvim_get_current_line()
				-- Lua 的字符串下标从 1 开始，col 表示当前位置左侧字符数
				local next_char = line:sub(col + 1, col + 1)
				-- 如果下一个字符是闭合对（例如 ) ] } ' " `），则跳过它
				if next_char:match("[%)%]%}'\"`]") then
					vim.api.nvim_win_set_cursor(0, { row, col + 1 })
				else
					-- 否则发送真实的 Tab 按键（不触发补全）
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
				end
			end

			local function jump_out_pair_backward_or_stab()
				local row, col = unpack(vim.api.nvim_win_get_cursor(0))
				local line = vim.api.nvim_get_current_line()
				local prev_char = line:sub(col, col)
				if prev_char:match("[%(%[%{'\"`]") then
					vim.api.nvim_win_set_cursor(0, { row, math.max(col - 1, 0) })
				else
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<S-Tab>", true, false, true), "n", false)
				end
			end

			-- 补全项类型图标（可用 lspkind 替换或扩展）
			local kind_icons = {
				Text = "󰉿",
				Method = "󰆧",
				Function = "",
				Constructor = "",
				Field = "󰜢",
				Variable = "",
				Class = "",
				Interface = "",
				Module = "",
				Property = "󰜢",
				Unit = "",
				Value = "󰎠",
				Enum = "󰕘",
				Keyword = "󰌋",
				Snippet = "",
				Color = "󰏘",
				File = "",
				Reference = "",
				Folder = "󰉋",
				EnumMember = "",
				Constant = "",
				Struct = "󰙅",
				Event = "",
				Operator = "󰆕",
				TypeParameter = "󰊄",
			}

			-- cmp 的主配置（只影响插入模式）
			cmp.setup({
				snippet = {
					expand = function(args)
						-- 当补全项是 snippet 时调用 luasnip 展开（若未安装 luasnip 则忽略）
						if luasnip then
							luasnip.lsp_expand(args.body)
						end
					end,
				},

				-- 映射：使用 cmp 提供的 preset 插入模式映射再做自定义
				mapping = cmp.mapping.preset.insert({
					["<CR>"] = cmp.mapping.confirm({ select = true }), -- 回车确认补全（未选择时会选择第一个）

					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							-- 补全可见时选择下一项
							cmp.select_next_item()
						elseif luasnip and luasnip.expand_or_jumpable() then
							-- snippet 可跳转时展开或跳转
							luasnip.expand_or_jump()
						else
							-- 退化为智能跳出配对或 Tab
							jump_out_pair_forward_or_tab()
						end
					end, { "i", "s" }),

					["<S-Tab>"] = cmp.mapping(function()
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip and luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							jump_out_pair_backward_or_stab()
						end
					end, { "i", "s" }),

					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-p>"] = cmp.mapping.close(),
				}),

				-- completion 选项（影响 vim 的 completeopt）
				completion = { completeopt = "menu,menuone" },

				-- formatting：控制补全列表的显示（左 -> 中 -> 右）
				formatting = {
					fields = { "kind", "abbr", "menu" },
					format = function(entry, vim_item)
						-- 关键改动：
						-- 仅显示图标作为 kind（不再拼接文字 "Text" 等），避免与候选文本重复出现
						vim_item.kind = (kind_icons[vim_item.kind] or "") -- 仅图标
						-- menu 用来显示来源简短标签（保持原样）
						vim_item.menu = ({
							luasnip = "[Snip]",
							buffer = "[Buf]",
							path = "[Path]",
							nvim_lsp = "[LSP]",
							vimtex = "[Vimtex]",
							omni = (vim.inspect(vim_item.menu):gsub('%"', "")),
							-- vimtex = vim_item.menu,
						})[entry.source.name] or ""
						return vim_item
					end,
				},

				-- 补全来源配置（按优先级排列）
				sources = cmp.config.sources({
					-- { name = "nvim_insert_text_lsp" },
					{ name = "luasnip" },
					-- { name = "treesitter" },
					{
						name = "buffer",
						option = {
							-- Visible buffer
							get_bufnrs = function()
								local bufs = {}
								for _, win in ipairs(vim.api.nvim_list_wins()) do
									bufs[vim.api.nvim_win_get_buf(win)] = true
								end
								return vim.tbl_keys(bufs)
							end,
						},
					},
					{ name = "nvim_lsp" },
					{ name = "path" },
					{
						name = "rg",
						keyword_length = 3,
						option = { -- 配置项表
							additional_arguments = "--hidden --max-depth 2", -- 额外传递给 ripgrep 的命令参数
							pattern = "[a-zA-Z_]+", -- 用于 ripgrep 匹配的正则表达式
							-- cwd = "..", -- 指定 ripgrep 搜索的根目录 父目录
							cwd = ".", -- 当前目录
							debounce = 500, -- 启动新 ripgrep 搜索前的防抖延迟（毫秒）
							context_before = 2, -- 补全文档窗口显示匹配项前的上下文行数
							context_after = 4, -- 补全文档窗口显示匹配项后的上下文行数
							-- debug = true, -- 输出 ripgrep stderr 进行调试
						},
					},
					{
						name = "latex_symbols",
						option = {
							strategy = 0, -- mixed
						},
					},
					{
						name = "vimtex",
					},
					{ name = "omni", trigger_characters = { "{", "\\" } },
					{
						name = "bufname",
						option = {
							-- use only current buffer for filename exractions
							current_buf_only = false,

							-- allows to configure what buffers to extract a filename from
							bufs = function()
								return vim.api.nvim_list_bufs()
							end,

							-- configure which entries you want to include in your completion:
							-- - you have to return a table of entries
							-- - empty string means skip that particular entry
							extractor = function(filename, full_path)
								return { filename:match("[^.]*") }
							end,
						},
					},
				}),

				-- 实验性功能：ghost_text（在文本后显示预测文本）
				experimental = { ghost_text = true },
			})
		end,
	},

	---------------------------------------------------------------------------
	-- 4. wilder.nvim：命令行补全的 UI 与 pipeline（替代 cmp-cmdline）
	--    说明：
	--      - wilder 提供命令行补全界面（类似补全菜单）与 pipeline（history、fuzzy、search 等）
	--      - 通过 expr 映射在 wilder 上下文使用 Tab 等键，否则保留原始行为
	---------------------------------------------------------------------------
	{
		"gelguy/wilder.nvim",
		event = "CmdlineEnter",
		dependencies = {
			{ "romgrk/fzy-lua-native", build = "make" }, -- 可选：本地编译的 fzy 算法用于提升 fuzzy 性能
		},
		config = function()
			local wilder = safe_require("wilder")
			if not wilder then
				vim.notify("wilder.nvim 未找到，跳过命令行增强配置", vim.log.levels.WARN)
				return
			end

			-- 只在命令行模式和搜索模式启用 wilder
			wilder.setup({ modes = { ":", "/", "?" } })

			-- 禁用 wilder 内置的 next/previous/accept/reject 键
			-- 因为我们使用 expr 映射来在 wilder 上下文中绑定键，而在普通上下文保持原有行为
			wilder.set_option("next_key", 0)
			wilder.set_option("previous_key", 0)
			wilder.set_option("accept_key", 0)
			wilder.set_option("reject_key", 0)

			-- highlighter：优先使用 pcre2_highlighter（若可用），否则 fallback 到 basic_highlighter
			local highlighters = {}
			if type(wilder.pcre2_highlighter) == "function" then
				table.insert(highlighters, wilder.pcre2_highlighter())
			end
			table.insert(highlighters, wilder.basic_highlighter())

			-- pipeline：命令行 fuzzy（lua_fzy 或 vim_fuzzy） + 搜索 pipeline
			local cmdline_pl = wilder.cmdline_pipeline({
				fuzzy = 1,
				-- 优先使用 lua_fzy_filter（需要 romgrk/fzy-lua-native），否则回退到 vim_fuzzy_filter
				fuzzy_filter = (type(wilder.lua_fzy_filter) == "function" and wilder.lua_fzy_filter())
					or wilder.vim_fuzzy_filter(),
			})
			local search_pl = wilder.search_pipeline()

			-- 组合 pipeline：
			--   - 输入为空时展示历史（最多 15 条）
			--   - 否则使用命令 fuzzy pipeline 或 search pipeline
			wilder.set_option(
				"pipeline",
				wilder.branch(
					{ wilder.check(function(_, x)
						return vim.fn.empty(x) == 1
					end), wilder.history(15) },
					cmdline_pl,
					search_pl
				)
			)

			-- renderer：popupmenu + 边框 + devicons + scrollbar（更接近系统补全）
			local renderer = wilder.popupmenu_renderer(wilder.popupmenu_border_theme({
				highlights = {
					border = "Normal",
					accent = "WilderAccent", -- 自定义高亮组（下面设置颜色）
					selected_accent = "WilderSelectedAccent",
				},
				highlighter = highlighters,
				left = { " ", wilder.popupmenu_devicons() }, -- 左侧显示文件类型图标
				right = { " ", wilder.popupmenu_scrollbar() }, -- 右侧显示滚动条
				max_height = 15,
				pumblend = 0, -- 菜单透明度（0 = 不透明）
			}))
			wilder.set_option("renderer", renderer)

			-- 设置自定义高亮（颜色可按主题改动）
			pcall(vim.api.nvim_set_hl, 0, "WilderAccent", { fg = "#00afaf" })
			pcall(vim.api.nvim_set_hl, 0, "WilderSelectedAccent", { fg = "#00afaf", bg = "#4e4e4e" })

			-- 键映射（expr 映射）：仅当 wilder#in_context() 为 true 时调用 wilder 的函数
			vim.api.nvim_set_keymap(
				"c",
				"<Tab>",
				"wilder#in_context() ? wilder#next() : '<Tab>'",
				{ noremap = true, expr = true, silent = true }
			)
			vim.api.nvim_set_keymap(
				"c",
				"<S-Tab>",
				"wilder#in_context() ? wilder#previous() : '<C-d>'",
				{ noremap = true, expr = true, silent = true }
			)
			vim.api.nvim_set_keymap(
				"c",
				"<Down>",
				"wilder#in_context() ? wilder#next() : '<Down>'",
				{ noremap = true, expr = true, silent = true }
			)
			vim.api.nvim_set_keymap(
				"c",
				"<Up>",
				"wilder#in_context() ? wilder#previous() : '<Up>'",
				{ noremap = true, expr = true, silent = true }
			)

			-- 如果使用 remote plugins（或刚装了本地编译依赖），更新 remote plugins（安全调用）
			pcall(vim.cmd, "silent! UpdateRemotePlugins")
		end,
	},
}
