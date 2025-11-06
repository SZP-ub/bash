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

}
