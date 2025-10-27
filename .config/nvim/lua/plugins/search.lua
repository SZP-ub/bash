---@diagnostic disable: undefined-global
return {
    {
        "romainl/vim-cool",
        keys = {
            { "n", mode = "n", desc = "清除高亮" }, -- 按下 n 触发高亮清除（vim-cool 自动处理，无需手动绑定）
            { "N", mode = "n", desc = "清除高亮" },
            { "*", mode = "n", desc = "清除高亮" },
            { "#", mode = "n", desc = "清除高亮" },
            { "?", mode = "n", desc = "清除高亮" },
            { "/", mode = "n", desc = "清除高亮" },
        },
    },

    {
        "ggandor/leap.nvim",
        keys = {
            { "s", mode = { "n", "x", "o" }, desc = "Leap 跳转" },
            { "S", mode = { "n", "x", "o" }, desc = "Leap 后向跳转" },
            { "gS", mode = "n", desc = "Leap 跨窗口后向跳转" },
        },
        config = function()
            -- 默认跳转
            vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap)")
            -- 跨窗口跳转
            vim.keymap.set("n", "S", "<Plug>(leap-from-window)")
            -- 可选：设置特殊按键
            require("leap").opts.special_keys.next_target = '<tab>'
        end,
    }
}
