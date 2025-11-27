---@diagnostic disable: undefined-global
return {

    {
        -- 加载 coc.nvim 插件，事件触发方式为 VeryLazy，分支选择 release
        "neoclide/coc.nvim",
        event = "VeryLazy",
        branch = "release",
        config = function()
            local fn = vim.fn
            local api = vim.api
            local uv = vim.loop

            -- 将字符串转为 neovim termcodes 并注入到输入队列
            local function feed_termcodes(keys, mode)
                mode = mode or "i"
                local t = api.nvim_replace_termcodes(keys, true, false, true)
                api.nvim_feedkeys(t, mode, true)
            end

            -- 检查补全菜单是否可见
            local function pum_visible() return fn['coc#pum#visible']() == 1 end
            -- 检查当前是否可以进行 coc 片段跳转或展开
            local function coc_expand_or_jump() return fn['coc#expandableOrJumpable']() == 1 end
            -- 检查当前是否可以向后跳 coc 片段占位符
            local function coc_jumpable_back() return fn['coc#jumpable'](-1) == 1 end

            -- 检查前面是否为空格（用于确定 Tab 行为）
            local function check_back_space()
                local col = fn.col('.') - 1
                if col == 0 then return true end
                return fn.getline('.'):sub(col, col):match('%s') ~= nil
            end

            -- tabout 仿真：如果当前为右括号等符号，则右移光标
            local function tabout_like()
                local col = fn.col('.')
                local ch = fn.getline('.'):sub(col, col)
                local t = { [")"] = 1, ["]"] = 1, ["}"] = 1, [">"] = 1, ["'"] = 1, ['"'] = 1, [";"] = 1, [","] = 1, ["`"] = 1 }
                return t[ch] and "<Right>" or nil
            end

            -- 防抖变量，避免 doKeymap 短时间多次调用（150ms 间隔）
            local last_doKeymap_ns = 0
            local DO_KEYMAP_MIN_INTERVAL_NS = 150 * 1e6 -- 150ms

            -- 通过 coc.rpc 的 doKeymap 实现跳转，并判断光标是否实际移动
            local function try_doKeymap_once(keyname)
                local now = uv.hrtime()
                if now - last_doKeymap_ns < DO_KEYMAP_MIN_INTERVAL_NS then
                    return false
                end
                last_doKeymap_ns = now

                local before = api.nvim_win_get_cursor(0)
                pcall(function()
                    fn['coc#rpc#request']("doKeymap", { keyname, "" })
                end)
                local after = api.nvim_win_get_cursor(0)
                return after[1] ~= before[1] or after[2] ~= before[2]
            end

            -- Tab 键处理函数（支持 Insert/Select 模式）
            local function tab_handler()
                if pum_visible() then
                    -- 若补全菜单打开，选中下一个条目
                    local ok, s = pcall(fn['coc#pum#next'], 1)
                    if ok and type(s) == "string" and #s > 0 then
                        feed_termcodes(s, "i")
                    else
                        feed_termcodes("<C-n>", "i")
                    end
                    return
                end

                -- 1. 如可跳 coc 片段，则优先跳转
                if coc_expand_or_jump() then
                    local ok, jumped = pcall(try_doKeymap_once, "snippets-expand-jump")
                    if ok and jumped then return end
                end

                -- 2. 若未检测到，依然尝试一次（带防抖）
                local ok_forced, forced = pcall(try_doKeymap_once, "snippets-expand-jump")
                if ok_forced and forced then return end

                -- 3. 尝试 tabout（右移出括号等符号）
                local k = tabout_like()
                if k then
                    feed_termcodes(k, "i")
                    return
                end

                -- 4. 插入 Tab 或触发补全
                if check_back_space() then
                    feed_termcodes("<Tab>", "i")
                else
                    pcall(fn['coc#refresh'])
                end
            end

            -- Shift-Tab 处理函数（支持 Insert/Select 模式）
            local function s_tab_handler()
                if pum_visible() then
                    -- 补全菜单时，选中上一个条目
                    local ok, s = pcall(fn['coc#pum#prev'], 1)
                    if ok and type(s) == "string" and #s > 0 then
                        feed_termcodes(s, "i")
                    else
                        feed_termcodes("<C-p>", "i")
                    end
                    return
                end

                -- 优先尝试 coc 片段向后跳转
                if coc_jumpable_back() then
                    local ok, jumped_back = pcall(try_doKeymap_once, "snippets-expand-jump-back")
                    if ok and jumped_back then return end
                end

                -- 强制再尝试一次跳转
                local ok_forced_back, forced_back = pcall(try_doKeymap_once, "snippets-expand-jump-back")
                if ok_forced_back and forced_back then return end

                -- 否则正常插入 Shift-Tab
                feed_termcodes("<S-Tab>", "i")
            end

            -- Enter 键处理（Insert/Select），保持补全确认行为
            local function cr_handler()
                if pum_visible() then
                    -- 如果补全菜单打开，确认补全
                    return fn['coc#pum#confirm']()
                else
                    -- 否则尝试调用 mini.pairs 的回车
                    local ok, mp = pcall(require, "mini.pairs")
                    if ok and mp and mp.cr then
                        return mp.cr()
                    else
                        return api.nvim_replace_termcodes("<CR>", true, false, true)
                    end
                end
            end

            -- 绑定 Insert / Select 模式下 Tab、Shift-Tab、Enter 的自定义行为
            vim.keymap.set({ "i", "s" }, "<Tab>", tab_handler, { noremap = true, silent = true })
            vim.keymap.set({ "i", "s" }, "<S-Tab>", s_tab_handler, { noremap = true, silent = true })
            vim.keymap.set({ "i", "s" }, "<CR>", cr_handler, { expr = true, silent = true, noremap = true })

            -- C-Space 手动触发补全（i 模式）
            vim.keymap.set("i", "<C-Space>", function() pcall(fn['coc#refresh']) end, { noremap = true, silent = true })

            -- 其余常用快捷键函数
            local nmap = function(lhs, rhs) vim.keymap.set("n", lhs, rhs, { silent = true }) end
            local xmap = function(lhs, rhs) vim.keymap.set("x", lhs, rhs, { silent = true }) end

            -- 跳转/重命名/查找定义等常用 LSP 功能
            nmap("gd", "<Plug>(coc-definition)")       -- 跳转到定义
            nmap("grt", "<Plug>(coc-type-definition)") -- 跳转到类型定义
            nmap("gi", "<Plug>(coc-implementation)")   -- 跳转到实现
            nmap("grn", "<Plug>(coc-rename)")          -- 重命名符号

            -- codeaction/修复/导入等
            xmap("gra", "<Plug>(coc-codeaction-selected)")                -- 可视选区代码操作
            nmap("<leader>a", "<Plug>(coc-codeaction-selected)")          -- 当前选中范围代码操作
            nmap("<leader>ac", "<Plug>(coc-codeaction-cursor)")           -- 光标处代码操作
            nmap("<leader>as", "<Plug>(coc-codeaction-source)")           -- 文件级 source action
            nmap("<leader>qf", "<Plug>(coc-fix-current)")                 -- 当前快速修复
            nmap("<leader>re", "<Plug>(coc-codeaction-refactor)")         -- 重构
            xmap("<leader>r", "<Plug>(coc-codeaction-refactor-selected)") -- 选区重构
            nmap("<leader>r", "<Plug>(coc-codeaction-refactor-selected)") -- 选区重构
            nmap("<leader>cl", "<Plug>(coc-codelens-action)")             -- codelens

            -- 文本对象增强：函数对象、类对象
            local objs = { { "f", "funcobj" }, { "c", "classobj" } }
            for _, o in ipairs(objs) do
                xmap("i" .. o[1], "<Plug>(coc-" .. o[2] .. "-i)") -- 内部函数/类
                vim.keymap.set("o", "i" .. o[1], "<Plug>(coc-" .. o[2] .. "-i)")
                xmap("a" .. o[1], "<Plug>(coc-" .. o[2] .. "-a)") -- 全部函数/类
                vim.keymap.set("o", "a" .. o[1], "<Plug>(coc-" .. o[2] .. "-a)")
            end

            -- 自定义 Fold 命令（CocAction fold）
            api.nvim_create_user_command("Fold", function(opts)
                fn.CocAction('fold', table.unpack(opts.fargs))
            end, { nargs = "?" })

            -- 自定义 OR 命令（组织导入）
            api.nvim_create_user_command("OR", function()
                fn.CocActionAsync('runCommand', 'editor.action.organizeImport')
            end, {})

            -- 悬浮窗优先滚动（<C-d>/<C-u>/j/k）
            api.nvim_set_keymap("n", "<C-d>",
                [[coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-d>"]],
                { noremap = true, silent = true, expr = true })
            api.nvim_set_keymap("n", "<C-u>",
                [[coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-u>"]],
                { noremap = true, silent = true, expr = true })
            api.nvim_set_keymap("n", "j",
                [[coc#float#has_scroll() ? coc#float#scroll(1, 1) : "gj"]],
                { noremap = true, silent = true, expr = true })
            api.nvim_set_keymap("n", "k",
                [[coc#float#has_scroll() ? coc#float#scroll(0, 1) : "gk"]],
                { noremap = true, silent = true, expr = true })

            -- CocList 相关快捷键（查看诊断、扩展等）
            nmap("<leader>ca", ":<C-u>CocList diagnostics<cr>") -- 显示诊断列表
            nmap("<leader>ce", ":<C-u>CocList extensions<cr>")  -- 显示扩展列表

            -- 光标悬停时高亮同名变量
            api.nvim_create_autocmd("CursorHold", {
                pattern = "*",
                callback = function() fn.CocActionAsync('highlight') end,
            })

            -- K 键悬停文档，如果 coc 支持则使用 coc hover，否则用默认 K
            local function show_doc()
                if fn.CocAction('hasProvider', 'hover') == 1 then
                    fn.CocActionAsync('doHover')
                else
                    feed_termcodes("K", "n")
                end
            end
            nmap("K", show_doc)
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
