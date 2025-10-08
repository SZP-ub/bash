---@diagnostic disable: undefined-global

-- ====================dot_to_arrow ==================
_G.dot_to_arrow = function()
    local col = vim.fn.col('.') - 2
    local line = vim.api.nvim_get_current_line()
    if col >= 0 and line:sub(col + 1, col + 1):match('%w') then
        return '->'
    else
        return '-'
    end
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "cpp" },
    callback = function()
        vim.api.nvim_buf_set_keymap(
            0, "i", "-", "v:lua.dot_to_arrow()", { expr = true, noremap = true }
        )
    end
})

-- ==================== 行号切换 ====================
local function ToggleLineNumbers()
    if vim.wo.relativenumber then
        vim.wo.relativenumber = false
    else
        vim.wo.relativenumber = true
        vim.wo.number = true
    end
end
vim.keymap.set("n", "<space>aa", ToggleLineNumbers, { silent = true, desc = "切换行号显示" })

-- ==================== 折叠 ====================
vim.keymap.set(
    "n",
    "<space>zf",
    "?^\\s*$<CR>jV/^\\s*$/-1<CR>zf",
    { silent = true, desc = "折叠段落（不含末尾空行）" }
)

-- ==================== buffer切换 ====================
vim.keymap.set("n", "<space>bb", ":buffers<cr>:buffer ", { noremap = true })
vim.keymap.set("n", "<space>e", ":tabnew ", { noremap = true })
vim.keymap.set("n", "<space>vs", ":lefta vs ", { noremap = true })
vim.keymap.set("n", "<space>w", ":w<cr>", { noremap = true })
vim.keymap.set("n", "<space>bn", "<C-^>", { noremap = true })
vim.keymap.set("n", "<Space>vw", ":vnew<CR>", { silent = true })
vim.keymap.set("n", "<space>nw", ':vnew<CR>:normal! "*p<CR>', { noremap = true })
vim.keymap.set("n", "<Space>br", "<C-w>r", { silent = true })
vim.keymap.set("n", "<Space>brr", "<C-w>R", { silent = true })
vim.keymap.set("n", "<space>df", ":diffthis<CR>", { noremap = true })

-- ==================== 智能关闭窗口或缓冲区 ====================
local function smart_close()
    local bufname = vim.fn.expand("%:t")
    if bufname:match("%.exe$") then
        vim.cmd("bdelete")
    else
        vim.cmd("quit")
    end
end
vim.keymap.set("n", "<space>q", smart_close, { silent = true, desc = "智能关闭窗口或缓冲区" })

-- ==================== 水平窗口切换 ====================
vim.keymap.set("n", "<C-l>", "<C-w>l", { silent = true })
vim.keymap.set("n", "<C-h>", "<C-w>h", { silent = true })
vim.keymap.set("i", "<C-l>", "<C-o><C-w>l", { silent = true })
vim.keymap.set("i", "<C-h>", "<C-o><C-w>h", { silent = true })

-- ==================== 垂直窗口切换 ====================
vim.keymap.set("n", "<C-j>", "<C-w>j", { silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { silent = true })
vim.keymap.set("i", "<C-j>", "<C-o><C-w>j", { silent = true })
vim.keymap.set("i", "<C-k>", "<C-o><C-w>k", { silent = true })

-- ==================== 高效退出键 ====================
vim.keymap.set("i", "jf", "<esc>")
vim.keymap.set("c", "jf", "<c-c>")
vim.keymap.set("n", "j", "gj", { noremap = true, silent = true })
vim.keymap.set("n", "k", "gk", { noremap = true, silent = true })
vim.keymap.set("n", "^", "g^")
vim.keymap.set("n", "gf", "gF")
vim.keymap.set("n", "J", "gJ")
vim.keymap.set('n', 'H', '^')
vim.keymap.set('n', 'L', 'g_')

-- ==================== ctrl组合键 ====================
vim.keymap.set("i", "<C-e>", "<Right>", { noremap = true, silent = true })

-- ==================== nvim-tree ====================
vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<space>tt', ':belowright vertical terminal<CR>')

-- ==================== 重命名文件 ====================
local function RenameInPlace()
    local oldname = vim.fn.expand('%:t')
    local dir = vim.fn.expand('%:p:h')
    local newname = vim.fn.input('Rename to: ', oldname)
    if newname == "" or newname == oldname then
        vim.notify("重命名已取消", vim.log.levels.INFO)
        return
    end
    local oldfile = dir .. "/" .. oldname
    local newfile = dir .. "/" .. newname
    local ok, err = os.rename(oldfile, newfile)
    if ok then
        vim.cmd('edit ' .. vim.fn.fnameescape(newfile))
        vim.cmd('silent! bwipeout #')
        vim.notify("重命名成功: " .. newname, vim.log.levels.INFO)
    else
        vim.notify("重命名失败! " .. (err or "未知错误"), vim.log.levels.ERROR)
    end
end
vim.keymap.set('n', '<space>rn', RenameInPlace, { desc = "重命名当前文件" })

-- ==================== 重构粘贴复制 ====================
vim.keymap.set('n', 'p', '""p', { noremap = true })
vim.keymap.set('v', 'p', '""p', { noremap = true })
vim.keymap.set('n', 'P', '""P', { noremap = true })
vim.keymap.set('v', 'P', '""P', { noremap = true })
vim.keymap.set('n', '<space>p', '"0p', { noremap = true })
vim.keymap.set('v', '<space>p', '"0p', { noremap = true })

-- ==================== 智能粘贴系统剪贴板内容到光标位置 ====================
vim.keymap.set('n', '<leader>p', function()
    -- 检查 buffer 是否可编辑
    if not vim.bo.modifiable then
        vim.notify("当前 buffer 不可编辑", vim.log.levels.WARN)
        return
    end

    local plus = vim.fn.getreg('+')
    local star = vim.fn.getreg('*')
    local to_paste = nil
    if plus ~= '' then
        to_paste = plus
    elseif star ~= '' then
        to_paste = star
    else
        vim.notify("剪贴板为空", vim.log.levels.WARN)
        return
    end

    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()
    local insert_pos = col + 1

    local before = line:sub(1, insert_pos)
    local after = line:sub(insert_pos + 1)

    local lines = vim.split(to_paste, "\n", true)
    local n = #lines

    if n == 1 then
        -- 单行内容，直接插入
        local new_line = before .. lines[1] .. after
        vim.api.nvim_set_current_line(new_line)
    else
        -- 多行内容，保持原格式
        local new_lines = {}
        new_lines[1] = before .. lines[1]
        for i = 2, n - 1 do
            table.insert(new_lines, lines[i])
        end
        new_lines[#new_lines + 1] = lines[n] .. after
        vim.api.nvim_buf_set_lines(0, row - 1, row, false, new_lines)
    end

    vim.notify(string.format("共插入 %d 行", n), vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = "智能粘贴系统剪贴板内容到光标后一位（保持格式）" })

-- ==================== 复制到系统剪贴板 ====================
local function copy_to_clipboard()
    local mode = vim.fn.mode()
    local lines_copied = 1
    if mode == 'v' or mode == 'V' or mode == '\22' then
        vim.cmd('normal! "+y')
        local start_line = vim.fn.line("v")
        local end_line = vim.fn.line(".")
        lines_copied = math.abs(end_line - start_line) + 1
    else
        vim.cmd('normal! "+yy')
    end
    vim.fn.setreg('*', vim.fn.getreg('+'))
    local msg = string.format("Copied %d line%s to system clipboard!", lines_copied, lines_copied > 1 and "s" or "")
    vim.notify(msg, vim.log.levels.INFO)
    vim.defer_fn(function()
        vim.notify("", vim.log.levels.INFO)
        vim.cmd("redraw")
    end, 1000)
end
vim.keymap.set({ 'n', 'v' }, '<leader>y', copy_to_clipboard, { noremap = true, silent = true })

-- ==================== 复制整个文件到剪贴板 ====================
vim.keymap.set("n", "<space>ac", function()
    vim.cmd("%y+")
    vim.cmd("%y*")
    vim.notify("Copied entire file to clipboard!", vim.log.levels.INFO)
end, { desc = "复制整个文件到剪贴板（+ 和 *）" })

-- ==================== vimdiff ====================
vim.keymap.set('n', '<leader>vd', function()
    local fullpath = vim.fn.expand('%:p')
    local filename = vim.fn.expand('%:t:r')
    local ext = vim.fn.expand('%:e')
    local dir = vim.fn.expand('%:p:h')
    local diff_file = string.format('%s/%s_diff.%s', dir, filename, ext)
    vim.cmd('vs ' .. vim.fn.fnameescape(diff_file))
    local plus = vim.fn.getreg('+')
    local star = vim.fn.getreg('*')
    local to_paste = {}
    if plus == star then
        to_paste = vim.split(plus, '\n', true)
    else
        vim.list_extend(to_paste, vim.split(plus, '\n', true))
        vim.list_extend(to_paste, vim.split(star, '\n', true))
    end
    local bufnr = vim.api.nvim_get_current_buf()
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    vim.api.nvim_buf_set_lines(bufnr, 0, line_count, false, {})
    vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, to_paste)
    vim.cmd('diffthis')
    vim.cmd('wincmd p')
    vim.cmd('diffthis')
end, { desc = "新建diff buffer并粘贴剪贴板内容进行diff" })

-- ==================== 编译运行 ====================
local function compile_and_run_c()
    vim.cmd("write")
    local src = vim.fn.expand("%:p")
    local filename = vim.fn.expand("%:t:r")
    local dir = vim.fn.expand("%:p:h")
    local ext = vim.fn.expand("%:e")
    local out = dir .. "/" .. filename .. ".out"
    local compiler, std_flag
    if ext == "c" then
        compiler = "gcc"
        std_flag = "-std=c17"
    else
        compiler = "g++"
        std_flag = "-std=c++17"
    end
    local cmd = string.format('%s -g %s "%s" -o "%s" 2>&1', compiler, std_flag, src, out)
    local result = vim.fn.systemlist(cmd)
    if vim.v.shell_error == 0 then
        -- 用 terminal 执行可执行文件
        vim.cmd("vsplit")
        vim.cmd("terminal " .. out)
        -- 可选：自动进入终端模式
        vim.cmd("startinsert")
    else
        local items = {}
        for _, line in ipairs(result) do
            local fname, lnum, col, text = string.match(line, '^([^:]+):(%d+):(%d+):%s*(.*)')
            if fname and lnum and col then
                table.insert(items, {
                    filename = fname,
                    lnum = tonumber(lnum),
                    col = tonumber(col),
                    text = text
                })
            elseif #line > 0 then
                table.insert(items, {
                    filename = src,
                    lnum = 1,
                    col = 1,
                    text = line
                })
            end
        end
        vim.fn.setqflist({}, ' ', { title = '编译错误', items = items })
        vim.cmd("vert copen")
        vim.cmd("vertical resize " .. math.floor(vim.o.columns / 2))
        vim.notify("编译失败！错误已显示在 quickfix 窗口", vim.log.levels.ERROR)
    end
end

vim.keymap.set('n', '<F1>', compile_and_run_c, { noremap = true, silent = true })

-- ==================== Quickfix 窗口快捷键映射 ====================
vim.keymap.set('n', '<Space>co', ':belowright copen<CR>', { noremap = true, silent = true, desc = '打开 quickfix 窗口' })
vim.keymap.set('n', '<Space>cc', ':cclose<CR>', { noremap = true, silent = true, desc = '关闭 quickfix 窗口' })
vim.keymap.set('n', '<Space>cn', ':cnext<CR>zz', { noremap = true, silent = true, desc = '跳转到下一个 quickfix 项' })
vim.keymap.set('n', '<Space>cp', ':cprev<CR>zz', { noremap = true, silent = true, desc = '跳转到上一个 quickfix 项' })
