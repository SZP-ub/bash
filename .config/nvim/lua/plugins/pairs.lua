---@diagnostic disable: undefined-global
return {

    {
        "echasnovski/mini.pairs",
        event = "VeryLazy",
        version = false, -- 使用最新主分支
        -- event = "InsertEnter", -- 在插入模式时加载
        config = function()
            require("mini.pairs").setup()
            -- 你可以在这里自定义配置，例如：
            -- require("mini.pairs").setup({
            --   mappings = {
            --     ["'"] = { action = "open", pair = "''", neigh_pattern = "[^%a\\]" },
            --   },
            -- })
        end,
    },

    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup()
        end,
        -- 快捷键
        -- ysiw) ：用括号包裹当前单词
        --  ys$" ：用双引号包裹到行尾
        -- ds] ：删除方括号包裹
        -- dst ：删除 HTML 标签包裹
        -- cs'" ：将单引号包裹改为双引号
        -- csth1<CR> ：将标签包裹改为 h1 标签
        -- dsf ：删除函数调用的括号包裹
    },


    {
        "HiPhish/rainbow-delimiters.nvim",
        event = "VeryLazy",
        config = function()
            require('rainbow-delimiters.setup').setup {
                strategy = {
                    [''] = 'rainbow-delimiters.strategy.global',
                    vim = 'rainbow-delimiters.strategy.local',
                },
                query = {
                    [''] = 'rainbow-delimiters',
                    lua = 'rainbow-blocks',
                },
                priority = {
                    [''] = 110,
                    lua = 210,
                },
            }
            vim.cmd [[
  hi MatchParen guibg=#444444 guifg=#ff8800 gui=bold
]]
        end,
    },
    {
        "sustech-data/wildfire.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("wildfire").setup({
                surrounds = {
                    { "(", ")" },
                    { "{", "}" },
                    { "<", ">" },
                    { "[", "]" },
                    { "`", "`" },
                },
                keymaps = {
                    init_selection = "<CR>",
                    node_incremental = "<CR>",
                    node_decremental = "<BS>",
                },
                filetype_exclude = { "qf" }, --keymaps will be unset in excluding filetypes
            })
        end,
    }
}
