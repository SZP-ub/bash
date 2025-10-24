---@diagnostic disable: undefined-global
return {
    {
        "numToStr/Comment.nvim",
        event = "VeryLazy",
        config = function()
            require('Comment').setup({
                toggler = {
                    block = 'gcb',
                },
            })
            -- 行尾注释快捷键
            vim.keymap.set('n', 'gca', function()
                vim.cmd('normal gcA')
            end, { desc = "行尾注释" })

            -- 针对 json 文件设置注释格式
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "json", "jsonc" },
                callback = function()
                    vim.bo.commentstring = "// %s"
                end,
            })
        end,
    }
}
