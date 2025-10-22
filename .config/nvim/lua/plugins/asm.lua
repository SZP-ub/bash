---@diagnostic disable: undefined-global
return {

    {
        "p00f/godbolt.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("godbolt").setup({
                languages = {
                    cpp = { compiler = "g122", options = {} }, -- C++ 使用 g122 编译器
                    c = { compiler = "cg122", options = {} },  -- C 使用 cg122 编译器
                },
                auto_cleanup = true,                           -- 关闭缓冲区时自动清理高亮和自动命令
                highlight = {
                    cursor = "Visual",                         -- 光标高亮使用 Visual 组（设置为 false 可禁用）
                    -- cursor = false,
                    -- static = { "#222222", "#333333", "#444444", "#555555", "#444444", "#333333" }, -- 静态高亮使用这些颜色
                    static = false, -- 可禁用静态高亮
                },
                -- highlight = false,          -- 可禁用所有高亮
                quickfix = {
                    enable = true,          -- 出错时是否填充 quickfix 列表
                    auto_open = true        -- 出错时是否自动打开 quickfix 列表
                },
                url = "https://godbolt.org" -- 可指定 Godbolt 实例地址
            })
        end,
    }
}
