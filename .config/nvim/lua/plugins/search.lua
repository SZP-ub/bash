---@diagnostic disable: undefined-global
return {

    {
        "romainl/vim-cool",
        event = "VeryLazy",
    },

    {
        "ggandor/leap.nvim",
        event = "VeryLazy",
        config = function()
            require("leap").add_default_mappings()
            vim.keymap.set('n', 'gS', '<Plug>(leap-backward-cross-window)')
            require("leap").opts.special_keys.next_target = '<tab>'
        end
    }

}
