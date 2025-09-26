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
            vim.keymap.set('n', 'gca', 'gcA', { remap = true, desc = "行尾注释" })
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "json",
                callback = function()
                    vim.bo.commentstring = "// %s"
                end,
            })
        end,
    }

}
