local utils = require("flua.utils")
local config = require("flua.config")

---@class flua
---@field buf buf_handle
---@field win win_handle
local flua = {}

---flua:setup sets user configuration
---@param cfg Config|nil
function flua:setup(cfg)
  cfg = cfg or {}
  self.config = vim.tbl_deep_extend('force', config, cfg)
end

---flua:_create_buf creates scratch buffer for flua
---@return buf_handle
function flua:_create_buf()
  if utils.is_buf_valid(self.buf) then
    return self.buf
  end

  local buf = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_buf_call(buf, function() vim.cmd("edit "..self.config.path) end)  -- load flua file into new buffer

  return buf
end

---flua:_create_win creates and opens new window for flua buffer
---@return win_handle
function flua:_create_win(buf)
  local dim = utils.get_dimension(self.config.dimensions)

  local win = vim.api.nvim_open_win(buf, true, {
    border = self.config.border,
    title = {
      {"Commands", "Special"}
    },
    title_pos = "center",
    relative = 'editor',
    style = 'minimal',
    width = dim.width,
    height = dim.height,
    col = dim.col,
    row = dim.row,
  })

  vim.api.nvim_win_set_option(win, 'winblend', self.config.blend)

  return win
end

---flua:_initialize initializes flua instance
function flua:_initialize()
  if self.config == nil then
    self:setup()
  end

  self.buf = self:_create_buf()
  self.source_file = vim.fn.tempname()

  vim.keymap.set("n", "<CR>", function()
    -- set marks
    vim.cmd('execute "normal! vip\\<esc>"')

    -- write desired command(s) to temp source file
    vim.cmd("silent '<,'>w! " .. self.source_file)

    self:_close()

    vim.cmd("luafile " .. self.source_file)
  end, {buffer = self.buf})

  vim.keymap.set("x", "<CR>", function()
    -- exit visual mode
    local esc = vim.api.nvim_replace_termcodes("<esc>", true, true, true)
    vim.api.nvim_feedkeys(esc, 'nx', false) -- 'x' mode makes feedkeys synchronous

    -- write desired command(s) to temp source file
    vim.cmd("silent '<,'>w! " .. self.source_file)

    self:_close()

    vim.cmd("luafile " .. self.source_file)
  end, {buffer = self.buf})
end

---flua:_open opens flua window
function flua:_open()
  -- initialize flua instance if haven't already
  if not utils.is_buf_valid(self.buf) then
    self:_initialize()
  end

  if utils.is_win_valid(self.win) then
    -- focus on window if it already exists
    vim.api.nvim_set_current_win(self.win)
  else
    -- create and open new window to flua buffer
    self.win = self:_create_win(self.buf)
  end

  -- format buffer so that commands are separated by one empty line
  if vim.fn.line('$') ~= 1 or vim.fn.match(vim.fn.getline(1), "^\\s*$") == -1 then
    utils.remove_eof_whitespace()
    vim.cmd('silent execute "normal! Go\\<CR>\\<esc>"')
    vim.cmd('silent w')
  end
  vim.cmd("normal! zz")
end

---flua:_write write the flua buffer
function flua:_write()
  vim.api.nvim_buf_call(self.buf, function() vim.cmd("silent w ++p") end)
end

---flua:_close closes flua window
function flua:_close()
  self:_write()
  vim.api.nvim_win_close(self.win, {})
end

---flua:toggle toggles visibility of flua window
function flua:toggle()
    if utils.is_win_valid(self.win) then
        self:_close()
    else
        self:_open()
    end
end

return flua
