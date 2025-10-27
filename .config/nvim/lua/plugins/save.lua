---@diagnostic disable: undefined-global
return {

    {
        "okuuva/auto-save.nvim",
        event = { "BufLeave", "WinLeave", "ModeChanged" }, -- 懒加载
        config = function()
            require("auto-save").setup({
                trigger_events = {
                    immediate_save = { "BufLeave", "WinLeave", "ModeChanged" },
                    defer_save = {},           -- 不用延迟保存事件
                    cancel_deferred_save = {}, -- 不用取消延迟事件
                },
                condition = function(buf)
                    return vim.bo[buf].modified and vim.bo[buf].buftype == ""
                end,
                debounce_delay = 0,
            })
        end,
    },

}
