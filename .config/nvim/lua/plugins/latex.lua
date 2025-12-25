---@diagnostic disable: undefined-global
return {
	-- vimtex: LaTeX support (compiler, synctex, viewer integration)
	{
		"lervag/vimtex",
		ft = { "tex", "bib" },
		config = function()
			-- 基本设置
			-- vim.cmd("syntax on")
			vim.g.tex_flavor = "latex"

			-- 编译器设置：latexmk（启用 synctex）
			vim.g.vimtex_compiler_method = "latexmk"
			vim.g.vimtex_compiler_autostart = 1
			vim.g.vimtex_compiler_start_on_save = 1
			vim.g.vimtex_compiler_latexmk = {
				executable = "latexmk",
				options = { "-xelatex", "-file-line-error", "-synctex=1", "-interaction=nonstopmode" },
				continuous = 0,
				callback = 0,
			}
			vim.g.vimtex_compiler_latexmk_clean_on_exit = 1
			vim.g.vimtex_clean_on_exit = 1

			-- 查看器：Sioyek
			vim.g.vimtex_view_method = "sioyek"
			vim.g.vimtex_quickfix_ignore_filters = {
				"Underfull",
				"Overfull",
				"specifier changed to",
				"Token not allowed in a PDF string",
				"LaTeX Warning: Float too large for page",
				"contains only floats",
			}

			-- Sioyek 逆向搜索（推荐用 nvr 连接正在运行的 Neovim）
			-- 若你使用 NVIM_LISTEN_ADDRESS 启动 nvim，会自动把地址加入调用命令
			local nvr_cmd = "nvr --remote-silent +%l %f"
			if vim.env.NVIM_LISTEN_ADDRESS and vim.env.NVIM_LISTEN_ADDRESS ~= "" then
				nvr_cmd = "NVIM_LISTEN_ADDRESS=" .. vim.env.NVIM_LISTEN_ADDRESS .. " " .. nvr_cmd
			end
			vim.g.vimtex_view_sioyek = {
				executable = "sioyek",
				arguments = {
					"--inverse-search",
					"nvr_cmd",
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
