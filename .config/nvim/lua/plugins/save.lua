---@diagnostic disable: undefined-global
return {

	-- {
	--     "okuuva/auto-save.nvim",
	--     event = "VeryLazy",
	--     -- event = { "BufLeave", "WinLeave", "ModeChanged" }, -- 懒加载
	--     config = function()
	--         require("auto-save").setup({
	--             trigger_events = {
	--                 immediate_save = { "BufLeave", "WinLeave", "ModeChanged" },
	--                 defer_save = {},           -- 不用延迟保存事件
	--                 cancel_deferred_save = {}, -- 不用取消延迟事件
	--             },
	--             condition = function(buf)
	--                 return vim.bo[buf].modified and vim.bo[buf].buftype == ""
	--             end,
	--             debounce_delay = 0,
	--         })
	--     end,
	-- },

	-- <leader>1~9 跳转到第N个窗口
	{
		"s1n7ax/nvim-window-picker",
		keys = (function()
			local keys = {}
			for i = 1, 9 do
				table.insert(keys, {
					"<leader>" .. i,
					function()
						local wins = vim.api.nvim_tabpage_list_wins(0)
						if wins[i] then
							vim.api.nvim_set_current_win(wins[i])
							vim.cmd("normal! zz")
						end
					end,
					desc = "跳转到窗口 " .. i,
				})
			end
			return keys
		end)(),
		config = false, -- 只用快捷键，不需要额外配置
	},

	-- 会话管理
	{
		"shatur/neovim-session-manager",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<leader>so", ":SessionManager load_session<cr>", desc = "加载会话" },
			{ "<leader>ss", ":SessionManager save_current_session<cr>", desc = "保存当前会话" },
			{ "<leader>sd", ":SessionManager delete_session<cr>", desc = "删除会话" },
			-- { "<leader>srn", nil, desc = "重命名 Session" },
		},
		config = function()
			local path = require("plenary.path")
			local config = require("session_manager.config")
			require("session_manager").setup({
				sessions_dir = path:new(vim.fn.stdpath("data"), "sessions"),
				autoload_mode = config.AutoloadMode.CurrentDir,
				autosave_last_session = false,
				autosave_ignore_not_normal = false,
				autosave_ignore_dirs = {},
				autosave_ignore_filetypes = { "lua" },
				autosave_only_in_session = false,
			})

			local session_dir = vim.fn.stdpath("data") .. "/sessions"
			local expire_days = 7

			local function clean_old_sessions()
				local files = vim.fn.globpath(session_dir, "*", false, true)
				local now = os.time()
				for _, file in ipairs(files) do
					local stat = vim.loop.fs_stat(file)
					if stat and stat.mtime then
						local diff_days = (now - stat.mtime.sec) / (60 * 60 * 24)
						if diff_days > expire_days then
							os.remove(file)
						end
					end
				end
			end
			clean_old_sessions()
		end,
	},
}
