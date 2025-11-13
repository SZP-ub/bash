---@diagnostic disable: undefined-global
return {

    {
        "neoclide/coc.nvim",
        branch = "release",
        event = "VeryLazy",
        config = function()
            local map, set = vim.api.nvim_set_keymap, vim.keymap.set
            local opts_expr = { noremap = true, silent = true, expr = true }
            local opts_silent = { silent = true }
            local opts_list = { silent = true, nowait = true }

            -- 判断光标是否在指定跳出符号前
            function _G.check_surround_pair()
                local col = vim.fn.col('.')
                if col == 0 then return false end
                local ch = vim.fn.getline('.'):sub(col, col)
                -- return ch:match("[,%)%]%}%>]") ~= nil
                return ch:match("[%)%]%}%>'\";,`]") ~= nil
            end

            -- 文档/hover
            local function show_doc()
                if vim.fn.CocAction('hasProvider', 'hover') then
                    vim.fn.CocActionAsync('doHover')
                else
                    vim.api.nvim_feedkeys('K', 'in', false)
                end
            end

            -- Snippet 跳转
            vim.g.coc_snippet_next = '<Tab>'
            vim.g.coc_snippet_prev = '<S-Tab>'

            -- 检查光标前是否是空白
            function _G.check_back_space()
                local col = vim.fn.col('.') - 1
                return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
            end

            -- 智能 <Tab> 增加跳出符号逻辑（必须一行！）
            map("i", "<Tab>",
                "coc#pum#visible() ? coc#pum#next(1) : coc#expandableOrJumpable() ? '<C-r>=coc#rpc#request(\"doKeymap\", [\"snippets-expand-jump\",\"\"])<CR>' : v:lua.check_surround_pair() ? '<Right>' : v:lua.check_back_space() ? '<Tab>' : coc#refresh()",
                { noremap = true, silent = true, expr = true }
            )
            map("i", "<S-Tab>",
                "coc#pum#visible() ? coc#pum#prev(1) : coc#jumpable(-1) ? '<C-r>=coc#rpc#request(\"doKeymap\", [\"snippets-expand-jump-back\",\"\"])<CR>' : '<S-Tab>'",
                { noremap = true, silent = true, expr = true }
            )

            -- <CR> 补全或 mini.pairs
            set("i", "<CR>", function()
                return vim.fn['coc#pum#visible']() == 1
                    and vim.fn['coc#pum#confirm']()
                    or require("mini.pairs").cr()
            end, { expr = true, silent = true, noremap = true })

            -- <C-Space> 补全
            set("i", "<C-Space>", "coc#refresh()", opts_expr)

            -- diagnostic 跳转
            set("n", "[g", "<Plug>(coc-diagnostic-prev)", opts_silent)
            set("n", "]g", "<Plug>(coc-diagnostic-next)", opts_silent)

            -- 定义 type impl
            set("n", "gd", "<Plug>(coc-definition)", opts_silent)
            set("n", "grt", "<Plug>(coc-type-definition)", opts_silent)
            set("n", "gi", "<Plug>(coc-implementation)", opts_silent)

            -- hover 文档
            set("n", "K", show_doc, opts_silent)

            -- 高亮 symbol/references
            vim.api.nvim_create_autocmd("CursorHold", {
                pattern = "*",
                callback = function()
                    vim.fn.CocActionAsync('highlight')
                end,
            })

            -- 重命名
            set("n", "grn", "<Plug>(coc-rename)", opts_silent)

            -- code actions
            set("x", "gra", "<Plug>(coc-codeaction-selected)", opts_silent)
            set("n", "<leader>a", "<Plug>(coc-codeaction-selected)", opts_silent)
            set("n", "<leader>ac", "<Plug>(coc-codeaction-cursor)", opts_silent)
            set("n", "<leader>as", "<Plug>(coc-codeaction-source)", opts_silent)
            set("n", "<leader>qf", "<Plug>(coc-fix-current)", opts_silent)

            -- refactor actions
            set("n", "<leader>re", "<Plug>(coc-codeaction-refactor)", opts_silent)
            set("x", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", opts_silent)
            set("n", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", opts_silent)
            set("n", "<leader>cl", "<Plug>(coc-codelens-action)", opts_silent)

            -- func/class 文本对象
            for _, obj in ipairs({ { "f", "funcobj" }, { "c", "classobj" } }) do
                set("x", "i" .. obj[1], "<Plug>(coc-" .. obj[2] .. "-i)")
                set("o", "i" .. obj[1], "<Plug>(coc-" .. obj[2] .. "-i)")
                set("x", "a" .. obj[1], "<Plug>(coc-" .. obj[2] .. "-a)")
                set("o", "a" .. obj[1], "<Plug>(coc-" .. obj[2] .. "-a)")
            end

            -- fold 命令
            vim.api.nvim_create_user_command("Fold", function(opts)
                if #opts.fargs > 0 then
                    vim.fn.CocAction('fold', unpack(opts.fargs))
                else
                    vim.fn.CocAction('fold')
                end
            end, { nargs = "?" })

            -- Organize Imports
            vim.api.nvim_create_user_command("OR", function()
                vim.fn.CocActionAsync('runCommand', 'editor.action.organizeImport')
            end, {})

            -- float window scroll/move
            local float_desc = { noremap = true, silent = true, expr = true, desc = "coc.nvim float scroll/move" }
            map("n", "<C-d>", [[coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-d>"]], float_desc)
            map("n", "<C-u>", [[coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-u>"]], float_desc)
            map("n", "j", [[coc#float#has_scroll() ? coc#float#scroll(1, 1) : "gj"]], float_desc)
            map("n", "k", [[coc#float#has_scroll() ? coc#float#scroll(0, 1) : "gk"]], float_desc)

            -- CocList 快捷键
            set("n", "<leader>ca", ":<C-u>CocList diagnostics<cr>", opts_list)
            set("n", "<leader>ce", ":<C-u>CocList extensions<cr>", opts_list)
            -- 下面可选（取消注释使用）
            -- set("n", "<leader>cc", ":<C-u>CocList commands<cr>", opts_list)
            -- set("n", "<leader>co", ":<C-u>CocList outline<cr>", opts_list)
            -- set("n", "<leader>cj", ":<C-u>CocNext<cr>", opts_list)
            -- set("n", "<leader>ck", ":<C-u>CocPrev<cr>", opts_list)
            -- set("n", "<leader>cp", ":<C-u>CocListResume<cr>", opts_list)

            -- 拼写检查插件 coc-spell-checker 快捷键
            -- <leader>aap 对当前段落进行拼写检查
            -- <leader>aw 对当前单词进行拼写检查
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
