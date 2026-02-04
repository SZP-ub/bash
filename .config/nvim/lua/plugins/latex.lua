---@diagnostic disable: undefined-global
return {

	-- vimtex: LaTeX support (compiler, synctex, viewer integration)
	{
		"lervag/vimtex",
		ft = { "tex", "bib" },
		config = function()
			-- 基本设置
			vim.g.tex_flavor = "latex"

			-- 编译器设置：latexmk（启用 synctex）
			vim.g.vimtex_compiler_method = "latexmk"
			vim.g.vimtex_compiler_autostart = 1
			vim.g.vimtex_compiler_start_on_save = 1
			vim.g.vimtex_compiler_latexmk = {
				executable = "latexmk",
				options = { "-xelatex", "-file-line-error", "-synctex=1", "-interaction=nonstopmode" },
				-- continuous = 0 表示 latexmk 运行结束后会退出（便于触发 clean_on_exit）
				continuous = 0,
				callback = 0,
			}
			-- 在 latexmk 退出时清理中间文件（如 .aux/.log/.out 等）
			vim.g.vimtex_compiler_latexmk_clean_on_exit = 1
			-- 退出时由 vimtex 执行额外清理（保留）
			vim.g.vimtex_clean_on_exit = 1

			-- 查看器：Sioyek
			vim.g.vimtex_view_method = "sioyek"

			-- quickfix 过滤：增加常见的警告模式以便不显示这些警告
			vim.g.vimtex_quickfix_ignore_filters = {
				"Underfull",
				"Overfull",
				"specifier changed to",
				"Token not allowed in a PDF string",
				"LaTeX Warning: Float too large for page",
				"contains only floats",
				-- 常见警告与包级警告
				"^LaTeX Warning:",
				"^Warning:",
				"^Package .* Warning:",
				"Reference .* undefined",
				"Citation .* undefined",
			}
			-- 当只有警告（no errors）时，不自动打开 quickfix 窗口
			vim.g.vimtex_quickfix_open_on_warning = 0

			-- Sioyek 逆向搜索（使用 nvr 连接正在运行的 Neovim）
			-- Sioyek 占位符：%1 = 文件路径，%2 = 行号
			-- nvr 需要的形式通常是: +<line> <file>，因此使用 +%2 %1
			local nvr_cmd = "nvr --remote-silent +%2 %1"
			-- 如果你使用 NVIM_LISTEN_ADDRESS 环境变量，让命令带上该变量
			if vim.env.NVIM_LISTEN_ADDRESS and vim.env.NVIM_LISTEN_ADDRESS ~= "" then
				nvr_cmd = "NVIM_LISTEN_ADDRESS=" .. vim.env.NVIM_LISTEN_ADDRESS .. " " .. nvr_cmd
			end
			vim.g.vimtex_view_sioyek = {
				executable = "sioyek",
				arguments = {
					"--inverse-search",
					nvr_cmd,
					"--reuse-instance",
					"--forward-search-file",
					"%{tex_file}",
					"--forward-search-line",
					"%{line}",
					"%{pdf_file}",
				},
			}

			-- 兼容性：确保 v:servername 存在（vtimex 老配置兼容）
			if vim.fn.exists("v:servername") == 0 or vim.v.servername == "" then
				vim.cmd([[let v:servername = 'vimtex']])
			end

			-- 文章目录 TOC 配置
			vim.g.vimtex_toc_config = {
				name = "TOC",
				layers = { "content", "todo", "include" },
				split_width = 25,
				todo_sorted = 0,
				show_help = 1,
				show_numbers = 1,
			}

			-- 文件类型映射（只在 tex buffer 生效）
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "tex",
				callback = function()
					local opts = { buffer = 0, noremap = true, silent = true }
					vim.keymap.set("n", "<leader>lv", "<plug>(vimtex-view)", opts)
					vim.keymap.set("n", "<leader>ll", "<plug>(vimtex-compile)", opts)
				end,
			})

			-- 保存时自动触发编译（与原 vimscript 保持一致）
			vim.api.nvim_create_autocmd("BufWritePost", {
				pattern = "*.tex",
				command = "VimtexCompile",
			})
		end,
	},
}
