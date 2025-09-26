---@diagnostic disable: undefined-global
return {

    -- 书签插件
    {
        "kshenoy/vim-signature",
    },

    -- 文件树侧边栏
    {
        "nvim-tree/nvim-tree.lua",
        event = "VeryLazy",
        config = function()
            require("nvim-tree").setup({
                sort_by = "case_sensitive",
                view = { width = 20 },
                renderer = { group_empty = true },
                filters = { dotfiles = true },
            })
        end,
    },

    -- 代码结构标签栏
    {
        "preservim/tagbar",
        event = "VeryLazy",
        cmd = "TagbarToggle",
        keys = {
            {
                "<leader>o",
                "<cmd>TagbarToggle<CR>",
                desc = "切换 Tagbar 代码结构窗口"
            }
        },
        config = function()
            vim.g.tagbar_autofocus = 1
            vim.g.tagbar_width = 30
            vim.g.tagbar_sort = 0
        end
    },

    -- fzf 二进制
    {
        "junegunn/fzf",
        event = "VeryLazy",
        build = "./install --bin",
    },

    {
        "ibhagwan/fzf-lua",
        event = "VeryLazy",
        config = function()
            require('fzf-lua').setup({

                winopts = {
                    -- split = "belowright new", -- 是否用分屏方式打开窗口？
                    -- "belowright new"  : 在下方分屏
                    -- "aboveleft new"   : 在上方分屏
                    -- "belowright vnew" : 在右侧分屏
                    -- "aboveleft vnew"  : 在左侧分屏
                    -- 只有在使用浮动窗口（即未设置 split 时，默认）才有效
                    height     = 0.85,    -- 窗口高度（占编辑区的百分比）
                    width      = 0.80,    -- 窗口宽度（占编辑区的百分比）
                    row        = 0.35,    -- 窗口顶部距离（0=最上，1=最下，0.35=靠上）
                    col        = 0.50,    -- 窗口左侧距离（0=最左，1=最右，0.5=居中）
                    border     = "solid", -- 边框样式，传递给 nvim_open_win()，如 "rounded" 圆角
                    backdrop   = 60,      -- 背景透明度，0为不透明，100为完全透明（即禁用）
                    -- title         = "Title",         -- 窗口标题
                    -- title_pos     = "center",        -- 标题位置：'left'、'center' 或 'right'
                    -- title_flags   = false,           -- 取消注释可禁用标题标志
                    fullscreen = false, -- 是否全屏显示窗口
                    -- treesitter 相关设置，仅对主窗口有 grep 类结果时生效
                    treesitter = {
                        enabled    = true,                                             -- 启用 treesitter 高亮
                        fzf_colors = { ["hl"] = "-1:reverse", ["hl+"] = "-1:reverse" } -- 高亮配色
                    },
                    preview    = {
                        -- default      = 'bat',       -- 指定预览器，默认用内置预览器
                        border       = "single",       -- 预览窗口边框样式
                        wrap         = true,           -- 预览内容是否自动换行
                        hidden       = false,          -- 预览窗口默认是否隐藏
                        vertical     = "down:45%",     -- 预览窗口垂直布局（向下，占45%）
                        horizontal   = "right:60%",    -- 预览窗口水平布局（向右，占60%）
                        layout       = "flex",         -- 预览窗口布局方式：horizontal|vertical|flex
                        flip_columns = 100,            -- 列数超过100时切换为水平布局
                        title        = true,           -- 预览窗口边框显示标题（文件名/缓冲区名）
                        title_pos    = "center",       -- 预览窗口标题居中
                        scrollbar    = "border",       -- 滚动条样式：'float' 浮动，'border' 边框，false 不显示
                        scrolloff    = -1,             -- 浮动滚动条距离右侧的偏移量
                        delay        = 20,             -- 预览显示延迟（毫秒），防止快速滚动时卡顿
                        winopts      = {               -- 内置预览器窗口选项
                            number         = true,     -- 显示行号
                            relativenumber = false,    -- 不显示相对行号
                            cursorline     = true,     -- 高亮当前行
                            cursorlineopt  = "both",   -- 高亮整行和光标列
                            cursorcolumn   = false,    -- 不高亮当前列
                            signcolumn     = "no",     -- 不显示标志列
                            list           = false,    -- 不显示列表字符
                            foldenable     = false,    -- 不启用折叠
                            foldmethod     = "manual", -- 折叠方式为手动
                        },
                    },
                    on_create  = function()
                        -- fzf 主窗口创建时调用
                        -- 可用于添加自定义 fzf-lua 映射，例如：
                        --   vim.keymap.set("t", "<C-j>", "<Down>", { silent = true, buffer = true })
                    end,
                    -- on_close = function() ... end -- fzf 窗口关闭后调用
                },

                fzf_opts = {
                    ['--cycle'] = '', -- 启用循环选择
                },

            })

            local fzf = require("fzf-lua")

            -- 文件查找
            vim.keymap.set('n', '<leader>ff', fzf.files, { desc = "fzf-lua: 查找文件" })
            -- 全文搜索（live_grep）
            vim.keymap.set('n', '<leader>fg', fzf.live_grep, { desc = "fzf-lua: 全文搜索" })
            -- 查找头文件（正则过滤 .h 结尾）
            vim.keymap.set('n', '<leader>fh', function()
                fzf.live_grep({ rg_opts = "--type-add 'header:*.h' --type header" })
            end, { desc = "fzf-lua: 查找头文件" })
            -- buffer 列表
            vim.keymap.set('n', '<leader>fb', fzf.buffers, { desc = "fzf-lua: buffer 列表" })
            -- 最近文件
            vim.keymap.set('n', '<leader>fr', fzf.oldfiles, { desc = "fzf-lua: 最近文件" })
            -- 查找包含当前文件的文件（#include "xxx"）
            vim.keymap.set('n', '<leader>fi', function()
                local fname = vim.fn.expand('%:t')
                fzf.live_grep({ search = '#include "' .. fname .. '"' })
            end, { desc = "fzf-lua: 查找包含当前文件的文件" })
            -- 查找 tags（ctags 需先生成）
            vim.keymap.set('n', '<leader>ft', fzf.tags, { desc = "fzf-lua: 查找 tags" })
            -- 查找调用关系（用当前光标单词搜索）
            vim.keymap.set('n', '<leader>fc', function()
                fzf.live_grep({ search = vim.fn.expand('<cword>') })
            end, { desc = "fzf-lua: 查找调用关系" })
        end,
    },

    -- cscope_maps.nvim 集成
    {
        "dhananjaylatkar/cscope_maps.nvim",
        dependencies = {
            "junegunn/fzf",
            "ibhagwan/fzf-lua",
            -- "junegunn/fzf.vim",
        },
        opts = {
            disable_maps = false,      -- 启用插件自带的默认快捷键
            skip_input_prompt = false, -- 查找时弹出输入提示
            prefix = "<leader>c",      -- cscope 相关操作的快捷键前缀

            cscope = {
                -- 数据库文件位置，项目根目录下
                db_file = "./cscope.out",
                exec = "cscope",                                           -- 使用 cscope 可执行文件
                picker = "fzf-lua",                                        -- 查找结果用 fzf.vim 弹窗展示
                skip_picker_for_single_result = false,                     -- 只有一个结果时也弹窗
                db_build_cmd = { script = "default", args = { "-bqkv" } }, -- 构建数据库命令
                statusline_indicator = nil,
                project_rooter = {
                    enable = false,
                    change_cwd = false,
                },
                tag = {
                    keymap = true,
                    order = { "cs", "tag_picker", "tag" },
                    tag_cmd = "tjump",
                },
            },

            stack_view = {
                tree_hl = true, -- 高亮调用关系树
            }
        },

        config = function(_, opts)
            require("cscope_maps").setup(opts)

            -- =========================
            -- cscope 相关快捷键（含中文注释）
            -- =========================

            -- 构建/更新 cscope 数据库（在项目根目录下执行）
            vim.keymap.set('n', '<leader>cb', ':!cscope -Rbqkv<CR>', { desc = "构建/更新 cscope 数据库（项目根目录）" })

            -- 打开调用关系树（stack view）
            vim.keymap.set('n', '<leader>csn', function()
                vim.cmd("CscopeStackView")
            end, { desc = "显示调用关系树（stack view）" })

            -- 递归多层跳转（stack view 中多层递归调用关系）
            vim.keymap.set('n', '<leader>cS', function()
                vim.cmd("CscopeStackViewJump")
            end, { desc = "递归多层跳转调用关系（stack view）" })

            -- 其他常用 cscope 查找（均用 fzf.vim 弹窗）
            -- vim.keymap.set('n', '<leader>css', "<cmd>Cscope find s <C-R><C-W><CR>", { desc = "查找符号（symbol）" })
            vim.keymap.set('n', '<leader>csg', "<cmd>Cscope find g <C-R><C-W><CR>",
                { desc = "查找全局定义（global definition）" })
            vim.keymap.set('n', '<leader>csc', "<cmd>Cscope find c <C-R><C-W><CR>", { desc = "查找调用该函数的位置（callers）" })
            vim.keymap.set('n', '<leader>csi', '<cmd>Cscope find c <C-R>=expand("<cword>")<CR><CR>',
                { desc = "Cscope: 调用我的函数" })
            vim.keymap.set('n', '<leader>cso', '<cmd>Cscope find d <C-R>=expand("<cword>")<CR><CR>',
                { desc = "Cscope: 我调用的函数" })
            vim.keymap.set('n', '<leader>cst', "<cmd>Cscope find t <C-R><C-W><CR>", { desc = "查找被该函数调用的位置（callees）" })
            -- vim.keymap.set('n', '<leader>cse', "<cmd>Cscope find e <C-R><C-W><CR>", { desc = "查找字符串（text string）" })
            -- vim.keymap.set('n', '<leader>csf', "<cmd>Cscope find f <C-R><C-W><CR>", { desc = "查找文件（file）" })
            -- vim.keymap.set('n', '<leader>csi', "<cmd>Cscope find i <C-R><C-W><CR>", { desc = "查找包含文件（#include）" })
        end,
    },

    -- 快捷键显示
    -- {
    --     "folke/which-key.nvim",
    --     event = "VeryLazy",
    --     config = function()
    --         require("which-key").setup()
    --     end,
    -- }
}
