---@diagnostic disable: undefined-global
return {

    {
        "neoclide/coc.nvim",
        event = "VeryLazy",
        branch = "release",
        config = function()
            -- K 显示文档（优先用 coc.nvim 的 hover，否则用内置 K）
            local function show_doc()
                if vim.fn.CocAction('hasProvider', 'hover') then
                    vim.fn.CocActionAsync('doHover')
                else
                    vim.api.nvim_feedkeys('K', 'in', false)
                end
            end

            -- snippet 跳转键
            vim.g.coc_snippet_next = '<Tab>'
            vim.g.coc_snippet_prev = '<S-Tab>'

            -- helper: 把 termcodes 转换并发送到 Neovim（feedkeys）
            local function feed_termcodes(keys, feed_mode)
                -- feed_mode 默认用 'n'（不让结果被再次映射）
                feed_mode = feed_mode or 'n'
                local t = vim.api.nvim_replace_termcodes(keys, true, false, true)
                vim.api.nvim_feedkeys(t, feed_mode, true)
            end

            -- 检查光标前是否是空白（局部函数，避免污染 _G）
            local function check_back_space()
                local col = vim.fn.col('.') - 1
                return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
            end

            -- tabout-like：括号/引号跳出（局部函数）
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
                if targets[next_char] then
                    return "<Right>"
                else
                    return "<Tab>"
                end
            end

            -- 智能 Tab 映射（补全、snippet、Tab、括号跳出）
            vim.keymap.set("i", "<Tab>", function()
                if vim.fn['coc#pum#visible']() == 1 then
                    -- coc 的下一个项通常会返回按键序列字符串，若不是则降级到 <C-n>
                    local ok, s = pcall(vim.fn['coc#pum#next'], 1)
                    if ok and type(s) == "string" and #s > 0 then
                        feed_termcodes(s)
                    else
                        feed_termcodes("<C-n>")
                    end
                    -- 非 expr 映射：不需要返回字符串
                    return
                elseif vim.fn['coc#expandableOrJumpable']() == 1 then
                    -- 触发 coc snippets expand/jump via rpc doKeymap
                    feed_termcodes('<C-r>=coc#rpc#request("doKeymap", ["snippets-expand-jump",""])<CR>')
                    return
                else
                    -- 括号/引号跳出或插入 Tab
                    local k = tabout_like()
                    feed_termcodes(k)
                    return
                end
            end, { noremap = true, silent = true })

            -- Shift-Tab 映射（补全、snippet、Shift-Tab）
            vim.keymap.set("i", "<S-Tab>", function()
                if vim.fn['coc#pum#visible']() == 1 then
                    local ok, s = pcall(vim.fn['coc#pum#prev'], 1)
                    if ok and type(s) == "string" and #s > 0 then
                        feed_termcodes(s)
                    else
                        feed_termcodes("<C-p>")
                    end
                    return
                elseif vim.fn['coc#jumpable'](-1) == 1 then
                    feed_termcodes('<C-r>=coc#rpc#request("doKeymap", ["snippets-expand-jump-back",""])<CR>')
                    return
                else
                    feed_termcodes("<S-Tab>")
                    return
                end
            end, { noremap = true, silent = true })

            -- 回车键：补全菜单可见时确认，否则用 mini.pairs 处理（需安装 mini.pairs 插件）
            vim.keymap.set("i", "<CR>", function()
                if vim.fn['coc#pum#visible']() == 1 then
                    -- 直接调用 coc 的确认函数（它会处理光标/插入等）
                    return vim.fn['coc#pum#confirm']()
                else
                    return require("mini.pairs").cr()
                end
            end, { expr = true, silent = true, noremap = true })

            -- <C-Space> 触发补全
            vim.keymap.set("i", "<C-Space>", "coc#refresh()", { expr = true, silent = true })

            -- [g / ]g 跳转诊断信息
            vim.keymap.set("n", "[g", "<Plug>(coc-diagnostic-prev)", { silent = true }) -- 上一个诊断
            vim.keymap.set("n", "]g", "<Plug>(coc-diagnostic-next)", { silent = true }) -- 下一个诊断

            -- 跳转到定义/类型定义/实现/引用
            vim.keymap.set("n", "gd", "<Plug>(coc-definition)", { silent = true })       -- 跳转到定义
            vim.keymap.set("n", "grt", "<Plug>(coc-type-definition)", { silent = true }) -- 跳转到类型定义
            vim.keymap.set("n", "gi", "<Plug>(coc-implementation)", { silent = true })   -- 跳转到实现
            -- vim.keymap.set("n", "gr", "<Plug>(coc-references)", { silent = true })      -- 查找引用

            -- K 显示文档
            vim.keymap.set("n", "K", show_doc, { silent = true }) -- 悬浮显示文档

            -- 光标悬停时高亮符号及引用
            vim.api.nvim_create_autocmd("CursorHold", {
                pattern = "*",
                callback = function()
                    vim.fn.CocActionAsync('highlight')
                end,
            })

            -- 重命名符号
            vim.keymap.set("n", "grn", "<Plug>(coc-rename)", { silent = true }) -- 重命名

            -- 选区代码操作
            vim.keymap.set("x", "gra", "<Plug>(coc-codeaction-selected)", { silent = true })       -- 选区代码操作
            vim.keymap.set("n", "<leader>a", "<Plug>(coc-codeaction-selected)", { silent = true }) -- 选区代码操作
            -- 光标处代码操作
            vim.keymap.set("n", "<leader>ac", "<Plug>(coc-codeaction-cursor)", { silent = true })  -- 光标处代码操作
            -- 整个 buffer 代码操作
            vim.keymap.set("n", "<leader>as", "<Plug>(coc-codeaction-source)", { silent = true })  -- buffer 代码操作
            -- 当前行诊断快速修复
            vim.keymap.set("n", "<leader>qf", "<Plug>(coc-fix-current)", { silent = true })        -- 快速修复

            -- 重构操作
            vim.keymap.set("n", "<leader>re", "<Plug>(coc-codeaction-refactor)", { silent = true })         -- 重构
            vim.keymap.set("x", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", { silent = true }) -- 选区重构
            vim.keymap.set("n", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", { silent = true }) -- 选区重构

            -- 运行当前行的 Code Lens
            vim.keymap.set("n", "<leader>cl", "<Plug>(coc-codelens-action)", { silent = true }) -- CodeLens

            -- 函数/类文本对象映射
            local objs = { { "f", "funcobj" }, { "c", "classobj" } }
            for _, obj in ipairs(objs) do
                vim.keymap.set("x", "i" .. obj[1], "<Plug>(coc-" .. obj[2] .. "-i)") -- 内部函数/类
                vim.keymap.set("o", "i" .. obj[1], "<Plug>(coc-" .. obj[2] .. "-i)")
                vim.keymap.set("x", "a" .. obj[1], "<Plug>(coc-" .. obj[2] .. "-a)") -- 外部函数/类
                vim.keymap.set("o", "a" .. obj[1], "<Plug>(coc-" .. obj[2] .. "-a)")
            end

            -- :Fold 命令折叠当前 buffer
            vim.api.nvim_create_user_command("Fold", function(opts)
                vim.fn.CocAction('fold', table.unpack(opts.fargs)) -- 折叠代码
            end, { nargs = "?" })

            -- :OR 命令组织导入
            vim.api.nvim_create_user_command("OR", function()
                vim.fn.CocActionAsync('runCommand', 'editor.action.organizeImport') -- 组织导入
            end, {})

            -- 悬浮窗优先滚动/移动
            local opts_float = { noremap = true, silent = true, expr = true, desc = "coc.nvim 悬浮窗优先滚动/移动" }
            vim.api.nvim_set_keymap("n", "<C-d>", [[coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-d>"]], opts_float)
            vim.api.nvim_set_keymap("n", "<C-u>", [[coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-u>"]], opts_float)
            vim.api.nvim_set_keymap("n", "j", [[coc#float#has_scroll() ? coc#float#scroll(1, 1) : "gj"]], opts_float)
            vim.api.nvim_set_keymap("n", "k", [[coc#float#has_scroll() ? coc#float#scroll(0, 1) : "gk"]], opts_float)

            -- CocList 相关映射（需定义 keyset 或用 vim.keymap.set 替换）
            local opts_list = { silent = true, nowait = true }
            vim.keymap.set("n", "<leader>ca", ":<C-u>CocList diagnostics<cr>", opts_list) -- 诊断列表
            vim.keymap.set("n", "<leader>ce", ":<C-u>CocList extensions<cr>", opts_list)  -- 扩展管理
            -- vim.keymap.set("n", "<leader>cc", ":<C-u>CocList commands<cr>", opts_list)    -- 命令列表
            -- vim.keymap.set("n", "<leader>co", ":<C-u>CocList outline<cr>", opts_list) -- 文档大纲（如需可取消注释）
            -- vim.keymap.set("n", "<leader>cj", ":<C-u>CocNext<cr>", opts_list)       -- 下一个 CocList 项
            -- vim.keymap.set("n", "<leader>ck", ":<C-u>CocPrev<cr>", opts_list)       -- 上一个 CocList 项
            -- vim.keymap.set("n", "<leader>cp", ":<C-u>CocListResume<cr>", opts_list) -- 恢复 CocList
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
