local utils = {}

---@alias buf_handle number
---@alias win_handle number

---@class Dimensions - Every field inside the dimensions should be b/w `0` to `1`
---@field height number: Height of the floating window (default: `0.8`)
---@field width number: Width of the floating window (default: `0.8`)
---@field x number: X-Axis of the floating window (default: `0.5`)
---@field y number: Y-Axis of the floating window (default: `0.5`)

---Create terminal dimension relative to the viewport
---@param opts Dimensions
---@return table
function utils.get_dimension(opts)
    -- Get lines and columns
    local cols = vim.o.columns
    local lines = vim.o.lines

    -- Calculate our floating window size
    local width = math.ceil(cols * opts.width)
    local height = math.ceil(lines * opts.height - 4)

    -- Calculate starting position
    local col = math.ceil((cols - width) * opts.x)
    local row = math.ceil((lines - height) * opts.y - 1)

    return {
        width = width,
        height = height,
        col = col,
        row = row,
    }
end

---Check whether the window is valid
---@param win win_handle
---@return boolean
function utils.is_win_valid(win)
    return win and vim.api.nvim_win_is_valid(win)
end

---Check whether the buffer is valid
---@param buf buf_handle
---@return boolean
function utils.is_buf_valid(buf)
    return buf and vim.api.nvim_buf_is_loaded(buf)
end

---Removes empty lines at end of file
function utils.remove_eof_whitespace()
  -- save position
  local pos = vim.fn.getcurpos()
  -- remove whitespace
  vim.cmd('execute "normal! Go\\<esc>dip"')
  -- restore position
  vim.fn.setpos('.', pos)
end

---Gets previously focused window's handle
function utils.get_prev_win()
  vim.cmd("wincmd p")
  local win = vim.api.nvim_get_current_win()
  vim.cmd("wincmd p")
  return win
end

return utils
