---@diagnostic disable: undefined-global
return {

	-- 书签插件
	{
		"chentoast/marks.nvim",
		event = "VeryLazy",
		keys = {
			{ "m", mode = "n", desc = "Marks: trigger (set/jump 标记时触发加载)" },
			{ "dm", mode = "n", desc = "Marks: 删除标记（dm{char} 交互式）" },
			{ "'", mode = "n", desc = "Marks: jump to mark (built-in) - trigger load" },
			{ "`", mode = "n", desc = "Marks: jump to mark (built-in) - trigger load" },
			{ "]`", mode = "n", desc = "Marks: next mark" },
			{ "[`", mode = "n", desc = "Marks: prev mark" },
		},
		config = function()
			local ok, marks = pcall(require, "marks")
			if not ok then
				vim.notify("marks.nvim not found", vim.log.levels.WARN)
				return
			end

			marks.setup({
				default_mappings = false,
				force_write_shada = false,
			})

			local map = vim.keymap.set
			local notify = vim.notify

			-- dm: 交互式删除：按 dm 后接字母（如 dmx 删除 mark x）
			map("n", "dm", function()
				-- 读取下一个按键（阻塞直到输入）
				local okc, c = pcall(vim.fn.getchar)
				if not okc or not c then
					return
				end
				local ch = vim.fn.nr2char(c)

				-- 只接受字母作为命名标记（a-z/A-Z）
				if not ch:match("%a") then
					notify("Invalid mark: " .. tostring(ch), vim.log.levels.WARN)
					return
				end

				-- 优先使用 marks.nvim 的内部 API 删除指定标记
				local deleted = false
				if marks.mark_state and type(marks.mark_state.delete_mark) == "function" then
					local ok_del, err = pcall(marks.mark_state.delete_mark, marks.mark_state, ch)
					if not ok_del then
						notify("marks.mark_state.delete_mark error: " .. tostring(err), vim.log.levels.WARN)
					else
						deleted = true
					end
				end

				-- 作为保险，调用内置 delmarks 命令（确保 Neovim 层面的标记也被移除）
				local ok_cmd, cmd_err = pcall(vim.cmd, "delmarks " .. ch)
				if not ok_cmd then
					notify("delmarks failed: " .. tostring(cmd_err), vim.log.levels.WARN)
				end

				-- 刷新显示（如果模块提供 refresh）
				if type(marks.refresh) == "function" then
					pcall(marks.refresh, true)
				end

				notify(
					string.format("Deleted mark '%s' (api=%s, delmarks=%s)", ch, tostring(deleted), tostring(ok_cmd)),
					vim.log.levels.INFO
				)
			end, { desc = "Marks: delete mark interactively (dm{char})" })

			-- 下一个 / 上一个 标记映射（调用 marks 模块的方法或回退）
			map("n", "]`", function()
				if type(marks.next) == "function" then
					pcall(marks.next)
				else
					pcall(vim.cmd, "normal! m]")
				end
			end, { desc = "Marks: next mark" })

			map("n", "[`", function()
				if type(marks.prev) == "function" then
					pcall(marks.prev)
				else
					pcall(vim.cmd, "normal! m[")
				end
			end, { desc = "Marks: previous mark" })

			-- 可选：preview 映射（若可用）
			if type(marks.preview) == "function" then
				map("n", "m:", function()
					pcall(marks.preview)
				end, { desc = "Marks: preview mark" })
			end
		end,
	},

	-- {
	-- 	"kshenoy/vim-signature",
	-- 	event = "VeryLazy",
	-- 	keys = {
	-- 		{ "m", mode = "n", desc = "添加/跳转标记" },
	-- 		{ "dm", mode = "n", desc = "删除标记" },
	-- 		{ "'", mode = "n", desc = "跳转到标记" },
	-- 		{ "`", mode = "n", desc = "跳转到标记" },
	-- 		{ "]`", mode = "n", desc = "下一个标记" },
	-- 		{ "[`", mode = "n", desc = "上一个标记" },
	-- 	},
	-- },

	-- 文件树侧边栏
	{
		"nvim-tree/nvim-tree.lua",
		-- cmd = "NvimTreeToggle", -- 只在打开文件树时加载
		keys = {
			{ "<C-n>", "<cmd>NvimTreeToggle<CR>", desc = "切换NvimTree" },
		},
		config = function()
			require("nvim-tree").setup({
				sort_by = "case_sensitive",
				view = { width = 40 },
				renderer = { group_empty = true },
				filters = { dotfiles = true },
			})
		end,
	},

	-- 代码结构标签栏
	{
		"preservim/tagbar",
		-- cmd = "TagbarToggle",
		keys = {
			{
				"<leader>o",
				"<cmd>TagbarToggle<CR>",
				desc = "切换 Tagbar 代码结构窗口",
			},
		},
		config = function()
			vim.g.tagbar_autofocus = 1
			vim.g.tagbar_width = 30
			vim.g.tagbar_sort = 0
		end,
	},
}
