---@diagnostic disable: undefined-global
return {

    -- 书签插件
    {
        "kshenoy/vim-signature",
        event = "VeryLazy",
        keys = {
            { "m", mode = "n", desc = "添加/跳转标记" },
            { "dm", mode = "n", desc = "删除标记" },
            { "'", mode = "n", desc = "跳转到标记" },
            { "`", mode = "n", desc = "跳转到标记" },
            { "]`", mode = "n", desc = "下一个标记" },
            { "[`", mode = "n", desc = "上一个标记" },
        },
    },

    -- 文件树侧边栏
    {
        "nvim-tree/nvim-tree.lua",
        cmd = "NvimTreeToggle", -- 只在打开文件树时加载
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
        cmd = "TagbarToggle",
        keys = {
            {
                "<leader>o",
                "<cmd>TagbarToggle<CR>",
                desc = "切换 Tagbar 代码结构窗口"
            }
        },
        config = function()
            vim.g.tagbar_autofocus = 1
            vim.g.tagbar_width = 30
            vim.g.tagbar_sort = 0
        end
    },

    -- fzf 二进制
    {
        "junegunn/fzf",
        lazy = true,
        build = "./install --bin",
    },

    {
        "junegunn/fzf.vim",
        event = "VeryLazy",
        dependencies = { "junegunn/fzf", "nvim-tree/nvim-web-devicons" },
        config = function()
            vim.keymap.set('n', '<space>ff', ':Files<CR>', { desc = "fzf: 查找文件" })
            vim.keymap.set('n', '<space>fg', ':Rg<CR>', { desc = "fzf: 全文搜索" })
            vim.keymap.set('n', '<space>fh', ":Rg \\.h$<CR>", { desc = "fzf: 查找头文件" })
            vim.keymap.set('n', '<space>fb', ':Buffers<CR>', { desc = "fzf: buffer 列表" })
            vim.keymap.set('n', '<space>fr', ':History<CR>', { desc = "fzf: 最近文件" })
            vim.keymap.set('n', '<space>fi', function()
                local fname = vim.fn.expand('%:t')
                vim.cmd("Rg #include \"" .. fname .. "\"")
            end, { desc = "fzf: 查找包含当前文件的文件" })
            vim.keymap.set('n', '<space>ft', ':Tags<CR>', { desc = "fzf: 查找 tags" })
            vim.keymap.set('n', 'grr', function()
                local word = vim.fn.expand('<cword>')
                vim.fn['fzf#vim#grep'](
                    'rg --column --line-number --no-heading --color=always --smart-case ' .. vim.fn.shellescape(word),
                    1,
                    vim.fn['fzf#vim#with_preview']({ options = { '--query', word } }),
                    0
                )
            end, { desc = "fzf: 查找调用关系" })
        end
    },

    {
        "ibhagwan/fzf-lua",
        lazy = true,
        dependencies = { "junegunn/fzf", "nvim-tree/nvim-web-devicons" },
        config = function()
            require("fzf-lua").setup({
                grep = {
                    actions = {
                        ["default"] = require("fzf-lua.actions").file_edit,
                    }
                },
                defaults = {
                    multi_select = false,
                },
                fzf_opts = {
                    ['--cycle'] = '',
                    ['--no-wrap'] = ''
                },
                winopts = {
                    height     = 0.75,
                    width      = 0.70,
                    row        = 0.35,
                    col        = 0.50,
                    border     = "solid",
                    backdrop   = 60,
                    fullscreen = false,
                    treesitter = {
                        enabled    = true,
                        fzf_colors = { ["hl"] = "-1:reverse", ["hl+"] = "-1:reverse" }
                    },
                    preview    = {
                        border       = "single",
                        wrap         = true,
                        hidden       = false,
                        vertical     = "down:45%",
                        horizontal   = "right:60%",
                        layout       = "flex",
                        flip_columns = 100,
                        title        = true,
                        title_pos    = "center",
                        scrollbar    = "border",
                        scrolloff    = 0,
                        delay        = 20,
                        winopts      = {
                            number         = true,
                            relativenumber = false,
                            cursorline     = true,
                            cursorlineopt  = "both",
                            cursorcolumn   = false,
                            signcolumn     = "no",
                            list           = false,
                            foldenable     = false,
                            foldmethod     = "manual",
                        },
                    },
                },
            })
        end,
    },

    {
        "dhananjaylatkar/cscope_maps.nvim",
        dependencies = { "ibhagwan/fzf-lua", "nvim-tree/nvim-web-devicons" },
        opts = {
            cscope = { db_file = "./cscope.out", picker = "quickfix", skip_picker_for_single_result = false },
            stack_view = { tree_hl = true },
        },
        keys = {
            { "csb", mode = "n", desc = "构建/更新 cscope 数据库" },
            { "csn", mode = "n", desc = "显示调用关系树（down）" },
            { "csu", mode = "n", desc = "显示被调用关系树（up）" },
            { "<space>csg", mode = "n", desc = "查找全局定义" },
            { "csc", mode = "n", desc = "查找调用该函数的位置" },
            { "cso", mode = "n", desc = "我调用的函数" },
            { "cst", mode = "n", desc = "查找被该函数调用的位置" },
            { "csa", mode = "n", desc = "查找赋值位置" },
        },
        config = function(_, opts)
            require("cscope_maps").setup(opts)
            vim.keymap.set('n', 'csb', ':!cscope -Rbqkv<CR>', { desc = "构建/更新 cscope 数据库（项目根目录）" })
            vim.keymap.set('n', 'csn', function()
                local word = vim.fn.expand('<cword>')
                if word ~= nil and word ~= "" then
                    vim.cmd("CsStackView open down " .. word)
                else
                    vim.notify("请将光标停在有效符号上再使用调用关系树", vim.log.levels.WARN)
                end
            end, { desc = "显示调用关系树（down）" })
            vim.keymap.set('n', 'csu', function()
                local word = vim.fn.expand('<cword>')
                if word ~= nil and word ~= "" then
                    vim.cmd("CsStackView open up " .. word)
                else
                    vim.notify("请将光标停在有效符号上再使用调用关系树", vim.log.levels.WARN)
                end
            end, { desc = "显示被调用关系树（up）" })
            vim.keymap.set('n', '<space>csg', ":Cs f g <C-R><C-W><CR>", { desc = "查找全局定义" })
            vim.keymap.set('n', 'csc', ":Cs f c <C-R><C-W><CR>", { desc = "查找调用该函数的位置" })
            vim.keymap.set('n', 'cso', ":Cs f d <C-R><C-W><CR>", { desc = "我调用的函数" })
            vim.keymap.set('n', 'cst', ":Cs f t <C-R><C-W><CR>", { desc = "查找被该函数调用的位置" })
            vim.keymap.set('n', 'csa', ":Cs f a <C-R><C-W><CR>", { desc = "查找赋值位置" })
        end,
    }

}
