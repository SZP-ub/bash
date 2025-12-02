---@diagnostic disable: undefined-global
return {

    {
        "nvim-treesitter/nvim-treesitter-context",
        event = "VeryLazy",
        -- ft = { "lua", "python", "javascript", "typescript", "rust", "c", "cpp", "go", "java", "sh", "vim", "markdown" },
        config = function()
            require("treesitter-context").setup({
                enable = true,
                multiwindow = true,
                max_lines = 2,
                min_window_height = 0,
                line_numbers = true,
                multiline_threshold = 2,
                trim_scope = 'inner',
                mode = 'topline',
                separator = nil,
                zindex = 2,
                on_attach = nil,
            })
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
            -- 颜色根据 colorscheme 变化时重置
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
                    char = "│",
                    -- char = "┆",
                },
                scope = {
                    enabled = true,
                },
                -- 在这些 filetype 中禁用 indent-blankline
                exclude = {
                    filetypes = {
                        "markdown", -- 关键：在 markdown 里不显示缩进线
                        "help",
                        "startify",
                        "dashboard",
                        "lazy",
                        "neo-tree",
                        "Trouble",
                        "alpha",
                    },
                },
            })

            hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
        end,
    },




    -- {
    --     "lukas-reineke/indent-blankline.nvim",
    --     event = "VeryLazy",
    --     config = function()
    --         local highlight = {
    --             "RainbowRed",
    --             "RainbowYellow",
    --             "RainbowBlue",
    --             "RainbowOrange",
    --             "RainbowGreen",
    --             "RainbowViolet",
    --             "RainbowCyan",
    --         }
    --
    --         local hooks = require "ibl.hooks"
    --         -- create the highlight groups in the highlight setup hook, so they are reset
    --         -- every time the colorscheme changes
    --         hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
    --             vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
    --             vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
    --             vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
    --             vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
    --             vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
    --             vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
    --             vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
    --         end)
    --
    --         require("ibl").setup({
    --             indent = {
    --                 highlight = highlight,
    --                 char = "│",
    --                 -- char = "┆",
    --             },
    --             scope = {
    --                 enabled = true,
    --             },
    --         })
    --
    --         local hooks = require "ibl.hooks"
    --         hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
    --     end,
    -- },

    -- 状态栏
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        config = function()
            -- vim.opt.laststatus = 2
            -- vim.opt.showtabline = 2

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
