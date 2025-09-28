---@diagnostic disable: undefined-global
return {

    {
        "neoclide/coc.nvim",
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

            -- 禁用备份文件，避免 LSP 兼容性问题
            vim.opt.backup = false
            vim.opt.writebackup = false
            vim.opt.signcolumn = "yes" -- 总是显示左侧标志栏

            -- snippet 跳转键
            vim.g.coc_snippet_next = '<Tab>'
            vim.g.coc_snippet_prev = '<S-Tab>'

            -- 检查光标前是否是空白
            function _G.check_back_space()
                local col = vim.fn.col('.') - 1
                return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
            end

            -- 智能 Tab 映射（补全、snippet、Tab）
            vim.api.nvim_set_keymap("i", "<Tab>",
                "coc#pum#visible() ? coc#pum#next(1) : coc#expandableOrJumpable() ? '<C-r>=coc#rpc#request(\"doKeymap\", [\"snippets-expand-jump\",\"\"])<CR>' : v:lua.check_back_space() ? '<Tab>' : coc#refresh()",
                { noremap = true, silent = true, expr = true })

            -- Shift-Tab 映射（补全、snippet、Shift-Tab）
            vim.api.nvim_set_keymap("i", "<S-Tab>",
                "coc#pum#visible() ? coc#pum#prev(1) : coc#jumpable(-1) ? '<C-r>=coc#rpc#request(\"doKeymap\", [\"snippets-expand-jump-back\",\"\"])<CR>' : '<S-Tab>'",
                { noremap = true, silent = true, expr = true })

            -- 回车键：补全菜单可见时确认，否则用 mini.pairs 处理（需安装 mini.pairs 插件）
            vim.keymap.set("i", "<CR>", function()
                if vim.fn['coc#pum#visible']() == 1 then
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
            vim.keymap.set("n", "gd", "<Plug>(coc-definition)", { silent = true })      -- 跳转到定义
            vim.keymap.set("n", "gy", "<Plug>(coc-type-definition)", { silent = true }) -- 跳转到类型定义
            vim.keymap.set("n", "gi", "<Plug>(coc-implementation)", { silent = true })  -- 跳转到实现
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

            -- <C-s> 选择范围
            vim.keymap.set("n", "<C-s>", "<Plug>(coc-range-select)", { silent = true }) -- 选择范围
            vim.keymap.set("x", "<C-s>", "<Plug>(coc-range-select)", { silent = true })

            -- 保存时自动格式化
            vim.api.nvim_create_autocmd("BufWritePre", {
                pattern = { "*.c", "*.cc", "*.json", "*.cpp", "*.h", "*.hpp", "*.lua", "*.cxx", "*.m", "*.mm" },
                callback = function()
                    vim.cmd('CocCommand editor.action.formatDocument') -- 保存时自动格式化
                end,
            })

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
            -- vim.keymap.set("n", "<leader>ce", ":<C-u>CocList extensions<cr>", opts_list)  -- 扩展管理
            -- vim.keymap.set("n", "<leader>cc", ":<C-u>CocList commands<cr>", opts_list)    -- 命令列表
            -- vim.keymap.set("n", "<leader>co", ":<C-u>CocList outline<cr>", opts_list) -- 文档大纲（如需可取消注释）
            -- vim.keymap.set("n", "<leader>cj", ":<C-u>CocNext<cr>", opts_list)       -- 下一个 CocList 项
            -- vim.keymap.set("n", "<leader>ck", ":<C-u>CocPrev<cr>", opts_list)       -- 上一个 CocList 项
            -- vim.keymap.set("n", "<leader>cp", ":<C-u>CocListResume<cr>", opts_list) -- 恢复 CocList

            -- ccls 专用命令和快捷键
            --             local ccls_cmds = {
            --                 Derived = { "$ccls/inheritance", { derived = true }, "查找派生类" },
            --                 Base = { "$ccls/inheritance", nil, "查找基类" },
            --                 VarAll = { "$ccls/vars", nil, "查找所有变量" },
            --                 VarLocal = { "$ccls/vars", { kind = 1 }, "查找局部变量" },
            --                 VarArg = { "$ccls/vars", { kind = 4 }, "查找参数变量" },
            --                 MemberFunction = { "$ccls/member", { kind = 3 }, "查找成员函数" },
            --                 MemberType = { "$ccls/member", { kind = 2 }, "查找成员类型" },
            --                 MemberVar = { "$ccls/member", { kind = 4 }, "查找成员变量" },
            --             }
            --             for name, v in pairs(ccls_cmds) do
            --                 -- 创建命令，执行相应 ccls 查询
            --                 vim.api.nvim_create_user_command(name, function()
            --                     vim.fn.CocLocations('ccls', v[1], v[2])
            --                 end, {})
            --             end
            --
            --             -- ccls 相关快捷键
            --             vim.keymap.set('n', 'grt', '<Cmd>MemberType<CR>', { silent = true, desc = '查找成员类型（ccls）' }) -- grt 查找成员类型
            --             vim.keymap.set('n', 'grv', '<Cmd>MemberVar<CR>', { silent = true, desc = '查找成员变量（ccls）' }) -- grv 查找成员变量
            --             vim.keymap.set('n', 'gc', function()
            --                 vim.fn.CocLocations('ccls', '$ccls/call') -- gc 查找当前符号的调用者
            --             end, { silent = true, desc = '查找当前符号的调用者（Callers）' })
            --             vim.keymap.set('n', 'gcc', function()
            --                 vim.fn.CocLocations('ccls', '$ccls/call', { callee = true }) -- gcc 查找当前符号调用的函数
            --             end, { silent = true, desc = '查找当前符号调用的函数（Callees）' })
            --
        end
    },

    {
        "gelguy/wilder.nvim",
        build = ":UpdateRemotePlugins", -- 安装后自动注册 remote plugin
        event = "CmdlineEnter",         -- 只在命令行模式加载
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
    }

}
