---@diagnostic disable: undefined-global
return {

    -- <leader>1~9 跳转到第N个窗口
    {
        "s1n7ax/nvim-window-picker",
        event = "VeryLazy",
        config = function()
            for i = 1, 9 do
                vim.keymap.set("n", "<leader>" .. i, function()
                    local wins = vim.api.nvim_tabpage_list_wins(0)
                    if wins[i] then
                        vim.api.nvim_set_current_win(wins[i])
                    end
                end, { desc = "跳转到窗口 " .. i })
            end
        end,
    },

    -- 会话管理
    {
        "shatur/neovim-session-manager",
        event = "VeryLazy",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local path = require("plenary.path")
            require("session_manager").setup({
                sessions_dir = path:new(vim.fn.stdpath("data"), "sessions"),
                autoload_mode = require("session_manager.config").autoload_mode.CurrentDir,
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

            vim.keymap.set("n", "<leader>so", ":SessionManager load_session<cr>", { desc = "加载会话" })
            vim.keymap.set("n", "<leader>ss", ":SessionManager save_current_session<cr>", { desc = "保存当前会话" })
            vim.keymap.set("n", "<leader>sd", ":SessionManager delete_session<cr>", { desc = "删除会话" })
        end,
    },

    -- 缩进线
    {
        "lukas-reineke/indent-blankline.nvim",
        event = "VeryLazy",
        config = function()
            require("ibl").setup({
                indent = { char = "┆" },
                scope = { enabled = true },
            })
        end,
    },

    -- 状态栏
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        config = function()
            vim.opt.laststatus = 2
            vim.opt.showtabline = 2

            require("lualine").setup({
                options = {
                    theme = "gruvbox_light",
                    icons_enabled = true,
                    always_divide_middle = true,
                    globalstatus = false,
                    component_separators = { left = '', right = '' },
                    section_separators = { left = '', right = '' },
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
                    lualine_c = {
                        "branch",
                        function()
                            local ok, nav = pcall(require, "coc-nav")
                            if ok and nav and type(nav.is_available) == "function" and nav.is_available() then
                                local status, loc = pcall(nav.get_location)
                                if status and loc and type(loc) == "string" and loc ~= "" then
                                    return loc
                                end
                            end
                            return ""
                        end,
                    },
                    lualine_z = {
                        function()
                            local bufnr = vim.api.nvim_get_current_buf()
                            local name = vim.fn.expand("%:t")
                            return string.format("❮%d❯ %s", bufnr, name)
                        end,
                    },
                    lualine_x = {},
                    lualine_y = {},
                },
                inactive_sections = {
                    lualine_b = {},
                    lualine_c = {
                        function()
                            return string.format("  %d ", vim.fn.winnr())
                        end,
                    },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {
                        function()
                            local bufnr = vim.api.nvim_get_current_buf()
                            local name = vim.fn.expand("%:t")
                            return string.format("《%d》%s", bufnr, name)
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
                                    string.format(
                                        "%s %d %s%s ",
                                        current,
                                        i,
                                        name,
                                        modified and " [+]" or ""
                                    )
                                )
                            end
                            return table.concat(tabs)
                        end,
                    },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {
                        'buffers',
                    },
                },
                extensions = {},
            })
        end,
    },



    -- 文件图标
    {
        "nvim-tree/nvim-web-devicons",
        event = "VeryLazy",
        config = function()
            require("nvim-web-devicons").setup({
                override = {},
                color_icons = true,
                default = true,
            })
        end,
    },
}
