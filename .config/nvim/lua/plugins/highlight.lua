---@diagnostic disable: undefined-global
return {

    {
        "nvim-treesitter/nvim-treesitter",
        -- event = { "BufReadPost", "BufNewFile" },
        event = "VeryLazy",
        build = ":TSUpdate",
        main = "nvim-treesitter.configs",
        opts = {
            auto_install = true,
            ensure_installed = {
                "cmake", "c", "cpp", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html", "json",
                "markdown",
                "latex",
            },
            sync_install = false,
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            indent = { enable = true },
        },
        opts_extend = { "ensure_installed" },
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
    },

    -- {
    --     "nvim-treesitter/nvim-treesitter-textobjects",
    --     dependencies = {},
    --     config = function()
    --         require("nvim-treesitter.configs").setup({
    --             textobjects = {
    --                 select = {
    --                     enable = true,
    --                     lookahead = true,
    --                     keymaps = {
    --                         ["af"] = "@function.outer",
    --                         ["if"] = "@function.inner",
    --                         ["ac"] = "@class.outer",
    --                         ["ic"] = "@class.inner",
    --                     },
    --                 },
    --                 move = {
    --                     enable = true,
    --                     set_jumps = true,
    --                     goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
    --                     goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
    --                 },
    --             },
    --         })
    --     end,
    -- },

}
