---@diagnostic disable: undefined-global
return {

    {
        "kshenoy/vim-signature",
    },

    {
        "nvim-tree/nvim-tree.lua",
        version = "VeryLazy",
        config = function()
            require("nvim-tree").setup({
                sort_by = "case_sensitive",
                view = {
                    width = 20,
                },
                renderer = {
                    group_empty = true,
                },
                filters = {
                    dotfiles = true,
                },
            })
        end,
    },

    {
        "preservim/tagbar",
        version = "VeryLazy",
        cmd = "TagbarToggle",
        keys = {
            {
                "<leader>o",
                "<cmd>TagbarToggle<CR>",
                desc = "Toggle Tagbar"
            }
        },
        config = function()
            vim.g.tagbar_autofocus = 1
            vim.g.tagbar_width = 30
            vim.g.tagbar_sort = 0
        end
    },

    -- {
    --     "liuchengxu/vista.vim",
    --     event = "VeryLazy",
    --     config = function()
    --         vim.g.vista_sidebar_width = 20
    --         -- 推荐用 ctags，markdown 没 LSP
    --         vim.g.vista_default_executive = 'ctags'
    --         vim.g.vista_close_on_jump = 0
    --         vim.keymap.set("n", "<leader>v", ":Vista!!<CR>", { noremap = true, silent = true, desc = "Toggle Vista" })
    --         vim.keymap.set("n", "<leader>V", ":Vista finder<CR>",
    --             { noremap = true, silent = true, desc = "Vista Finder" })
    --     end,
    -- },

    --     {
    --
    --         "stevearc/symbols-outline.nvim",
    --         event = "VeryLazy",
    --         cmd = "SymbolsOutline",
    --         dependencies = {
    --             "nvim-tree/nvim-web-devicons", -- 图标支持
    --         },
    --         keys = {
    --             {
    --                 "<leader>o",
    --                 "<cmd>SymbolsOutline<CR>",
    --                 desc = "Toggle Symbols Outline"
    --             }
    --         },
    --         config = function()
    --             local ok, outline = pcall(require, "symbols-outline")
    --             if not ok then
    --                 vim.notify("symbols-outline.nvim 加载失败", vim.log.levels.ERROR)
    --                 return
    --             end
    --             outline.setup({
    --                 width = 25,                    -- 侧边栏宽度
    --                 autofold_depth = 1,            -- 默认折叠层级
    --                 auto_close = false,            -- 不自动关闭
    --                 show_symbol_details = true,    -- 显示符号详情
    --                 highlight_hovered_item = true, -- 高亮悬停项
    --                 show_guides = true,            -- 显示缩进线
    --             })
    --         end
    --     },


}
