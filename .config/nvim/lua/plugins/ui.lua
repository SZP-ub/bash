---@diagnostic disable: undefined-global
return {

    {
        "nvim-treesitter/nvim-treesitter-context",
        event = "VeryLazy",
        config = function()
            require("treesitter-context").setup({
                enable = true,           -- 启用此插件（也可以通过命令随时启用/禁用）
                multiwindow = true,      -- 是否支持多窗口（多分屏时每个窗口都显示上下文）
                max_lines = 2,           -- 上下文窗口最多显示多少行（小于等于0表示不限制行数）
                min_window_height = 0,   -- 编辑器窗口最小高度，低于此高度不显示上下文（小于等于0表示不限制）
                line_numbers = true,     -- 是否显示行号
                multiline_threshold = 2, -- 单个上下文最多显示多少行（超过则折叠）
                trim_scope = 'inner',    -- 当超过 max_lines 时，丢弃哪部分上下文（'inner' 丢弃内部，'outer' 丢弃外部）
                mode = 'topline',        -- 用哪一行来计算上下文（'cursor' 用光标所在行，'topline' 用窗口顶部行）
                separator = nil,         -- 上下文和正文之间的分隔符（如 '-'，设置后只有光标上方至少有2行时才显示上下文）
                zindex = 2,              -- 上下文窗口的 Z-index（层级，数字越大越靠上）
                on_attach = nil,         -- 附加到 buffer 时的回调函数，返回 false 可禁用上下文显示
            })
        end,
    },

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
                    desc = "跳转到窗口 " .. i
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

    -- 缩进线
    {
        "lukas-reineke/indent-blankline.nvim",
        event = "VeryLazy",
        config = function()
            local highlight = {
                "RainbowRed",
                "RainbowYellow",
                "RainbowBlue",
                "RainbowOrange",
                "RainbowGreen",
                "RainbowViolet",
                "RainbowCyan",
            }

            local hooks = require "ibl.hooks"
            -- create the highlight groups in the highlight setup hook, so they are reset
            -- every time the colorscheme changes
            hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
                vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
                vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
                vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
                vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
                vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
                vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
                vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
            end)

            require("ibl").setup({
                indent = {
                    highlight = highlight,
                    -- char = "┆",
                },
                scope = {
                    enabled = true,
                },
            })

            local hooks = require "ibl.hooks"
            hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
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
            vim.api.nvim_create_autocmd("VimResized", {
                callback = function()
                    vim.cmd("LualineUpdate")
                end,
            })
        end,
    },

    -- 文件图标
    {
        "nvim-tree/nvim-web-devicons",
        -- event = "VeryLazy",
        lazy = true,
        config = function()
            require("nvim-web-devicons").setup({
                override = {},
                color_icons = true,
                default = true,
            })
        end,
    },
}
