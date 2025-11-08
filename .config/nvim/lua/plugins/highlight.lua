---@diagnostic disable: undefined-global
return {

    {
        "nvim-treesitter/nvim-treesitter",
        -- event = { "BufReadPost", "BufNewFile" },
        -- event = "VeryLazy",
        ft = { "lua", "python", "javascript", "typescript", "rust", "c", "cpp", "go", "java", "sh", "vim", "markdown" },
        build = ":TSUpdate",
        main = "nvim-treesitter.configs",
        opts = {
            auto_install = true,
            ensure_installed = {
                "cmake", "c", "cpp", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html", "json",
                "markdown",
                -- "latex",
            },
            sync_install = false,
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            indent = { enable = true },
        },
        opts_extend = { "ensure_installed" },
    },

    {
        "sustech-data/wildfire.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        keys = {
            { "<CR>", mode = { "n", "x" }, desc = "wildfire 区块选择/扩展" },
            { "<BS>", mode = { "n", "x" }, desc = "wildfire 区块收缩" },
        },
        config = function()
            require("wildfire").setup({
                surrounds = {
                    { "(", ")" },
                    { "{", "}" },
                    { "<", ">" },
                    { "[", "]" },
                    { "`", "`" },
                },
                keymaps = {
                    init_selection = "<CR>",
                    node_incremental = "<CR>",
                    node_decremental = "<BS>",
                },
                filetype_exclude = { "qf" },
            })
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        dependencies = {
            "nvim-treesitter/nvim-treesitter", -- 确保 treesitter core 可用；lazy 会自动按需加载依赖
        },

        keys = {
            -- textobject 选择（operator-pending / visual）
            -- { "af",         mode = { "o", "x" } }, -- operator/visual：选中整个函数（a-function）
            -- { "if",         mode = { "o", "x" } }, -- operator/visual：选中函数内部（i-function）
            -- { "ac",         mode = { "o", "x" } }, -- 选中类（outer）
            -- { "ic",         mode = { "o", "x" } }, -- 选中类（inner）
            -- { "ap",         mode = { "o", "x" } }, -- 参数 outer
            -- { "ip",         mode = { "o", "x" } }, -- 参数 inner
            -- { "ab",         mode = { "o", "x" } }, -- 代码块 outer（示例）
            -- { "ib",         mode = { "o", "x" } }, -- 代码块 inner（示例）

            -- move 映射（普通模式）
            -- { "]f",         mode = "n" }, -- 跳到下一个函数起始
            -- { "[f",         mode = "n" }, -- 跳到上一个函数起始
            -- { "]F",         mode = "n" }, -- 跳到下一个函数结束
            -- { "[F",         mode = "n" }, -- 跳到上一个函数结束

            -- swap（普通模式）
            { "gsp", mode = "n" }, -- 将当前参数与下一个参数交换（lazy 首次按键触发加载）
            { "gsP", mode = "n" }, -- 将当前参数与上一个参数交换

            -- lsp_interop peek（普通模式）
            -- { "<leader>df", mode = "n" }, -- peek 函数定义（浮窗预览）
            -- { "<leader>dF", mode = "n" }, -- peek 类定义（浮窗预览）
        },

        config = function()
            require("nvim-treesitter.configs").setup({
                -- 按需启用/安装解析器（建议在单独位置管理 ensure_installed）
                -- ensure_installed = { "lua", "python", "javascript", "typescript", "c", "cpp", "java" },

                -- 启用基于 treesitter 的语法高亮（便于 textobject 更准确）
                -- highlight = { enable = true },

                -- 启用基于 treesitter 的缩进（可选，按需打开/关闭）
                -- indent = { enable = true },

                textobjects = {
                    -- select = {
                    --     enable = true,
                    --     lookahead = true, -- 启用向前查找，下达选择命令时会跳到最近的匹配（类似 targets.vim 的体验）
                    --     keymaps = {
                    --         -- ["af"] = "@function.outer",  -- a-function：包含函数定义的外层（含签名/修饰）
                    --         -- ["if"] = "@function.inner",  -- i-function：仅选函数体内部
                    --         -- ["ac"] = "@class.outer",     -- a-class：类的外层
                    --         -- ["ic"] = "@class.inner",     -- i-class：类的内部
                    --         -- ["ap"] = "@parameter.outer", -- a-parameter：参数外层
                    --         -- ["ip"] = "@parameter.inner", -- i-parameter：参数内部
                    --         -- ["ab"] = "@block.outer",     -- a-block：代码块外层（示例，query 语义依语言）
                    --         -- ["ib"] = "@block.inner",     -- i-block：代码块内部
                    --     },
                    --     -- 可按 capture 指定选择模式（字符/行/块），如需可在这里启用
                    --     -- selection_modes = {
                    --     --   ["@parameter.outer"] = "v", -- 字符选择
                    --     --   ["@function.outer"]  = "v", -- 行选择
                    --     --   ["@class.outer"]     = "<c-v>", -- 块选择（可视块）
                    --     -- },
                    --     include_surrounding_whitespace = false, -- 是否包含周围空白（false：只选语义节点）
                    -- },

                    -- move = {
                    --     enable = true,
                    --     set_jumps = true, -- 把跳转位置记录到 jumplist，便于 <c-o> 回退
                    --     -- goto_next_start：跳到下一个 textobject 的起始处
                    --     goto_next_start = {
                    --         ["]f"] = "@function.outer",
                    --         -- ["]c"] = "@class.outer", -- 如需类跳转可取消注释
                    --     },
                    --     -- goto_next_end：跳到下一个 textobject 的结束处（通常绑定大写字母）
                    --     goto_next_end = {
                    --         ["]f"] = "@function.outer",
                    --         -- ["]c"] = "@class.outer",
                    --     },
                    --     goto_previous_start = {
                    --         ["[f"] = "@function.outer",
                    --         -- ["[c"] = "@class.outer",
                    --     },
                    --     goto_previous_end = {
                    --         ["[f"] = "@function.outer",
                    --         -- ["[c"] = "@class.outer",
                    --     },
                    -- },

                    swap = {
                        enable = true,
                        -- swap_next / swap_previous,               -- 用于交换参数等（重构非常实用）
                        swap_next = {
                            ["gsp"] = "@parameter.inner", -- 将当前参数与下一个参数交换
                        },
                        swap_previous = {
                            ["gsp"] = "@parameter.inner", -- 将当前参数与上一个参数交换
                        },
                    },

                    -- lsp_interop = {
                    --     enable = true,
                    --     peek_definition_code = {
                    --         ["<leader>dF"] = "@function.outer", -- 在浮窗中预览函数定义（无需跳转）
                    --         ["<leader>df"] = "@class.outer",    -- 在浮窗中预览类定义
                    --     },
                    -- },
                },
            })
        end,
    }

}
