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
                -- "latex",
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
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        keys = {
            { "<CR>", mode = { "n", "x" }, desc = "wildfire 区块选择/扩展" },
            { "<BS>", mode = { "n", "x" }, desc = "wildfire 区块收缩" },
        },
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
                filetype_exclude = { "qf" },
            })
        end,
    }

}
