local M = {}

--- Creates a buffer
--- @param buf_name string: Name of the buffer
--- @param writeable boolean: Whether the buffer is writeable
--- @return integer: Buffer number
function M.create_buffer(buf_name, writeable)
  local bufnr = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_name(bufnr, buf_name)
  if not writeable then
    vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
  else
    vim.api.nvim_set_option_value("buftype", "acwrite", { buf = bufnr })
  end
  vim.api.nvim_set_option_value("swapfile", false, { buf = bufnr })
  vim.api.nvim_set_option_value("buflisted", false, { buf = bufnr })

  return bufnr
end

--- Creates a split window for a buffer
--- @param bufnr integer: Buffer number
function M.create_split (bufnr)
  vim.api.nvim_command("vnew")
  vim.api.nvim_command("vertical resize 50")

  local new_winnr = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(new_winnr, bufnr)
  vim.api.nvim_win_set_option(new_winnr, "wrap", false)
  vim.api.nvim_win_set_option(new_winnr, "number", false)
  vim.api.nvim_win_set_option(new_winnr, "relativenumber", false)

  return new_winnr
end

--- Hides a window
--- @param winnr integer: Window number
function M.hide_window (winnr)
  vim.api.nvim_win_hide(winnr)
end

--- Updates a buffer with new lines
--- @param bufnr integer: Buffer number
--- @param lines table: Lines to update the buffer with
function M.update(bufnr, lines)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end

--- Appends lines to a buffer
--- @param bufnr integer: Buffer number
--- @param lines table: Lines to append to buffer
function M.append(bufnr, lines)
  vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, lines)
end


return M
