---@diagnostic disable: undefined-global
return {

	{
		"lervag/vimtex",
		-- ft = { "tex", "bib" },
		lazy = false,
		config = function()
			vim.g.tex_flavor = "latex"

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

			vim.g.vimtex_view_method = "zathura"

			local listen = vim.env.NVIM_LISTEN_ADDRESS or "/tmp/nvimsocket"

			vim.g.vimtex_view_zathura = {
				executable = "zathura",
				options = {
					"--synctex-editor-command",
					"NVIM_LISTEN_ADDRESS=" .. listen .. " nvr --remote-silent +%l %f",
				},
			}

			vim.g.vimtex_quickfix_ignore_filters = {
				"Underfull",
				"Overfull",
				"specifier changed to",
				"Token not allowed in a PDF string",
				"LaTeX Warning: Float too large for page",
				"contains only floats",
				"^LaTeX Warning:",
				"^Warning:",
				"^Package .* Warning:",
				"Reference .* undefined",
				"Citation .* undefined",
			}
			vim.g.vimtex_quickfix_open_on_warning = 0

			if vim.fn.exists("v:servername") == 0 or vim.v.servername == "" then
				vim.cmd([[let v:servername = 'vimtex']])
			end

			vim.g.vimtex_toc_config = {
				name = "TOC",
				layers = { "content", "todo", "include" },
				split_width = 25,
				todo_sorted = 0,
				show_help = 1,
				show_numbers = 1,
			}

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "tex",
				callback = function()
					local opts = { buffer = 0, noremap = true, silent = true }
					vim.keymap.set("n", "<space>lv", "<plug>(vimtex-view)", opts)
					vim.keymap.set("n", "<space>ll", "<plug>(vimtex-compile)", opts)
				end,
			})

			-- vim.api.nvim_create_autocmd("BufWritePost", {
			-- 	pattern = "*.tex",
			-- 	command = "VimtexCompile",
			-- })
		end,
	},
}
