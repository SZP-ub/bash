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

    {
        "junegunn/fzf",
        version = "VeryLazy",
        build = "./install --bin",
    },
    {
        "junegunn/fzf.vim",
        dependencies = { "junegunn/fzf" },
        version = "VeryLazy",
        config = function()
            -- 设置fzf界面为输入框在顶部，列表从上到下
            -- vim.env.FZF_DEFAULT_OPTS = '--layout=default'
            -- vim.env.FZF_DEFAULT_OPTS = (vim.env.FZF_DEFAULT_OPTS or '') .. ' --layout=default'

            -- 文件查找
            vim.keymap.set('n', '<leader>ff', ':Files<CR>', { noremap = true, silent = true, desc = "fzf: 查找文件" })
            -- 全文搜索
            vim.keymap.set('n', '<leader>fg', ':RG ', { noremap = true, silent = false, desc = "fzf: 全文搜索" })
            -- 查找头文件
            vim.keymap.set('n', '<leader>fh', ':RG \\.h$<CR>', { noremap = true, silent = true, desc = "fzf: 查找头文件" })
            -- buffer列表
            vim.keymap.set('n', '<leader>fb', ':Buffers<CR>', { noremap = true, silent = true, desc = "fzf: buffer列表" })
            -- 最近文件
            vim.keymap.set('n', '<leader>fr', ':History<CR>', { noremap = true, silent = true, desc = "fzf: 最近文件" })
            -- 查找包含当前文件的文件
            vim.keymap.set('n', '<leader>fi', function()
                local fname = vim.fn.expand('%:t')
                vim.cmd('RG #include "' .. fname .. '"')
            end, { noremap = true, silent = false, desc = "fzf: 查找包含当前文件的文件" })
            -- 查找 tags（函数/变量/宏等）
            vim.keymap.set('n', '<leader>ft', ':Tags<CR>', { noremap = true, silent = true, desc = "fzf: 查找tags" })
            -- 查找调用关系（用 ripgrep 搜索函数名）
            vim.keymap.set('n', '<leader>fc', ':Rg <C-R><C-W><CR>',
                { noremap = true, silent = false, desc = "fzf: 查找调用关系" })

            -- LSP 调用关系（需 lspsaga 或 telescope 支持）
            -- vim.keymap.set('n', '<leader>ci', '<cmd>Lspsaga incoming_calls<CR>', { desc = "LSP: 调用我的函数" })
            -- vim.keymap.set('n', '<leader>co', '<cmd>Lspsaga outgoing_calls<CR>', { desc = "LSP: 我调用的函数" })
        end,
    }

}
