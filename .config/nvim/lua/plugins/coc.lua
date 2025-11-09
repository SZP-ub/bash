---@diagnostic disable: undefined-global
return {

    {
        "neoclide/coc.nvim",
        event = "VeryLazy",
        branch = "release",
        config = function()
            local unpack = table.unpack

            -- 发送终端键码，与 Neovim 交互输入函数
            local function feed_termcodes(keys, feed_mode)
                feed_mode = feed_mode or 'n'
                local t = vim.api.nvim_replace_termcodes(keys, true, false, true)
                vim.api.nvim_feedkeys(t, feed_mode, true)
            end

            -- 智能 Tab 键跳转，如果下一个字符是右括号/引号等就跳过去，否则正常 Tab
            local function tabout_like()
                local col = vim.fn.col('.')
                local line = vim.fn.getline('.')
                local next_char = line:sub(col, col)
                local targets = {
                    [")"] = true,
                    ["]"] = true,
                    ["}"] = true,
                    [">"] = true,
                    ["'"] = true,
                    ['"'] = true,
                    [";"] = true,
                    [","] = true,
                    ["`"] = true
                }
                return targets[next_char] and "<Right>" or "<Tab>"
            end

            -- 显示函数/变量文档，支持 Coc hover 或默认 K
            local function show_doc()
                if vim.fn.CocAction('hasProvider', 'hover') then
                    vim.fn.CocActionAsync('doHover')
                else
                    vim.api.nvim_feedkeys('K', 'in', false)
                end
            end

            -- 插入模式下键位映射
            local function imap(lhs, rhs, opts)
                vim.keymap.set("i", lhs, rhs,
                    vim.tbl_extend("force", { noremap = true, silent = true }, opts or {}))
            end
            -- 普通模式下键位映射
            local function nmap(lhs, rhs, opts)
                vim.keymap.set("n", lhs, rhs,
                    vim.tbl_extend("force", { silent = true }, opts or {}))
            end
            -- 可视模式下键位映射
            local function xmap(lhs, rhs, opts)
                vim.keymap.set("x", lhs, rhs,
                    vim.tbl_extend("force", { silent = true }, opts or {}))
            end
            -- 操作符等待模式下键位映射
            local function omap(lhs, rhs, opts)
                vim.keymap.set("o", lhs, rhs,
                    vim.tbl_extend("force", { silent = true }, opts or {}))
            end

            -- snippet 跳转快捷键
            vim.g.coc_snippet_next = '<Tab>'
            vim.g.coc_snippet_prev = '<S-Tab>'

            -- 智能 Tab 映射
            imap("<Tab>", function()
                if vim.fn['coc#pum#visible']() == 1 then -- 若补全菜单可见，跳到下一个
                    local ok, s = pcall(vim.fn['coc#pum#next'], 1)
                    feed_termcodes(ok and type(s) == "string" and #s > 0 and s or "<C-n>")
                elseif vim.fn['coc#expandableOrJumpable']() == 1 then -- 若 snippet 可扩展或跳转，跳转
                    feed_termcodes('<C-r>=coc#rpc#request("doKeymap", ["snippets-expand-jump",""])<CR>')
                else                                                  -- 正常 tab 或右移
                    feed_termcodes(tabout_like())
                end
            end)

            -- 智能 Shift-Tab 映射
            imap("<S-Tab>", function()
                if vim.fn['coc#pum#visible']() == 1 then -- 补全菜单可见，跳到上一个
                    local ok, s = pcall(vim.fn['coc#pum#prev'], 1)
                    feed_termcodes(ok and type(s) == "string" and #s > 0 and s or "<C-p>")
                elseif vim.fn['coc#jumpable'](-1) == 1 then -- snippet 可后退
                    feed_termcodes('<C-r>=coc#rpc#request("doKeymap", ["snippets-expand-jump-back",""])<CR>')
                else                                        -- 正常 Shift-Tab
                    feed_termcodes("<S-Tab>")
                end
            end)

            -- 智能回车：补全时选中，否则 mini.pairs 回车补全
            imap("<CR>", function()
                if vim.fn['coc#pum#visible']() == 1 then
                    return vim.fn['coc#pum#confirm']()
                else
                    return require("mini.pairs").cr()
                end
            end, { expr = true })

            -- 基本功能快捷键映射
            nmap("[g", "<Plug>(coc-diagnostic-prev)")  -- 跳转到上一个诊断
            nmap("]g", "<Plug>(coc-diagnostic-next)")  -- 跳转到下一个诊断
            nmap("gd", "<Plug>(coc-definition)")       -- 跳转到定义
            nmap("grt", "<Plug>(coc-type-definition)") -- 跳转到类型定义
            nmap("gi", "<Plug>(coc-implementation)")   -- 跳转到实现
            nmap("K", show_doc)                        -- 悬浮显示文档
            -- 自动高亮光标下 symbol
            vim.api.nvim_create_autocmd("CursorHold", {
                pattern = "*",
                callback = function()
                    vim.fn.CocActionAsync('highlight')
                end,
            })
            nmap("grn", "<Plug>(coc-rename)")                             -- 重命名
            xmap("gra", "<Plug>(coc-codeaction-selected)")                -- 可视模式下代码操作
            nmap("<leader>a", "<Plug>(coc-codeaction-selected)")          -- leader+a 代码操作
            nmap("<leader>ac", "<Plug>(coc-codeaction-cursor)")           -- leader+ac 光标下代码操作
            nmap("<leader>as", "<Plug>(coc-codeaction-source)")           -- leader+as 源码级别代码操作
            nmap("<leader>qf", "<Plug>(coc-fix-current)")                 -- 修复当前问题
            nmap("<leader>re", "<Plug>(coc-codeaction-refactor)")         -- leader+re 重构操作
            xmap("<leader>r", "<Plug>(coc-codeaction-refactor-selected)") -- 可视模式下重构
            nmap("<leader>r", "<Plug>(coc-codeaction-refactor-selected)") -- 普通模式下重构
            nmap("<leader>cl", "<Plug>(coc-codelens-action)")             -- leader+cl 代码 lens

            -- 函数对象/类对象文本对象，支持可视和操作符等待模式
            for _, obj in ipairs({ { "f", "funcobj" }, { "c", "classobj" } }) do
                xmap("i" .. obj[1], "<Plug>(coc-" .. obj[2] .. "-i)")
                omap("i" .. obj[1], "<Plug>(coc-" .. obj[2] .. "-i)")
                xmap("a" .. obj[1], "<Plug>(coc-" .. obj[2] .. "-a)")
                omap("a" .. obj[1], "<Plug>(coc-" .. obj[2] .. "-a)")
            end

            -- 折叠命令，兼容所有 Lua 版本
            vim.api.nvim_create_user_command("Fold", function(opts)
                if #opts.fargs > 0 then
                    vim.fn.CocAction('fold', unpack(opts.fargs))
                else
                    vim.fn.CocAction('fold')
                end
            end, { nargs = "?" })

            -- 快速整理 import 命令
            vim.api.nvim_create_user_command("OR", function()
                vim.fn.CocActionAsync('runCommand', 'editor.action.organizeImport')
            end, {})

            -- 悬浮窗优先滚动/移动快捷键（用 expr 判断，兼容悬浮和正常滚动）
            local opts_float = { noremap = true, silent = true, expr = true, desc = "coc.nvim 悬浮窗优先滚动/移动" }
            vim.api.nvim_set_keymap("n", "<C-d>", [[coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-d>"]], opts_float)
            vim.api.nvim_set_keymap("n", "<C-u>", [[coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-u>"]], opts_float)
            vim.api.nvim_set_keymap("n", "j", [[coc#float#has_scroll() ? coc#float#scroll(1, 1) : "gj"]], opts_float)
            vim.api.nvim_set_keymap("n", "k", [[coc#float#has_scroll() ? coc#float#scroll(0, 1) : "gk"]], opts_float)

            local opts_list = { silent = true, nowait = true }
            nmap("<leader>ca", ":<C-u>CocList diagnostics<cr>", opts_list) -- leader+ca 打开诊断列表
            nmap("<leader>ce", ":<C-u>CocList extensions<cr>", opts_list)  -- leader+ce 打开扩展列表
            -- nmap("<leader>cc", ":<C-u>CocList commands<cr>", opts_list) -- leader+cc 打开命令列表（已注释）
            -- nmap("<leader>co", ":<C-u>CocList outline<cr>", opts_list) -- leader+co 打开 outline（已注释）
            -- nmap("<leader>cj", ":<C-u>CocNext<cr>", opts_list) -- Coc 补全下一个（已注释）
            -- nmap("<leader>ck", ":<C-u>CocPrev<cr>", opts_list) -- Coc 补全上一个（已注释）
            -- nmap("<leader>cp", ":<C-u>CocListResume<cr>", opts_list) -- 恢复 CocList（已注释）

            -- 拼写检查插件 coc-spell-checker 快捷键
            -- <leader>aap 对当前段落进行拼写检查
            -- nmap("<leader>aap", "<Plug>(coc-spell-checker-codeaction-paragraph)")
            -- <leader>aw 对当前单词进行拼写检查
            -- nmap("<leader>aw", "<Plug>(coc-spell-checker-codeaction-word)")
        end
    },


    {
        "romgrk/fzy-lua-native",
        lazy = true,
        build = "make",
    },

    {
        "gelguy/wilder.nvim",
        build = ":UpdateRemotePlugins",
        -- event = "InsertEnter", -- 改为在进入插入模式时加载
        keys = { ":", "/", "?" }, -- 按下这些键时加载插件
        dependencies = {
            "romgrk/fzy-lua-native",
        },
        config = function()
            local wilder = require('wilder')
            wilder.setup({ modes = { ':', '/', '?' } })
            wilder.set_option('use_select', true)
            wilder.set_option('pipeline', {
                wilder.branch(
                    wilder.cmdline_pipeline({
                        fuzzy = 1,
                        fuzzy_filter = wilder.lua_fzy_filter(),
                    }),
                    wilder.search_pipeline()
                )
            })

            wilder.set_option('renderer', wilder.popupmenu_renderer(
                wilder.popupmenu_border_theme({
                    border = 'rounded',
                    highlights = { accent = 'WilderAccent' },
                    highlighter = wilder.basic_highlighter(),
                })
            ))
        end,
    },

}
