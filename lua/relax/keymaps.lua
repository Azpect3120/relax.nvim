local requests = require("relax.requests")

local M = {}

--- Function to handle the enter event in the window
--- @param swapnr number: The previous window number
function Enter_event(swapnr)
  local line = vim.api.nvim_get_current_line()
  local linenr = vim.api.nvim_win_get_cursor(0)[1]

  if (string.find(line, "New")) then
    requests.new(swapnr)
  elseif (string.find(line, "Past")) then
    requests.show_history()
  elseif (string.find(line, "Clear")) then
    requests.clear_history()
  end
end

--- Set the key mappings for the window UI
--- @param bufnr number: The buffer number
--- @param swapnr number: The previous window number
function M.setUIMappings(bufnr, swapnr)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "N", "<cmd>lua print('New request')<cr>", { noremap = true })
  vim.api.nvim_buf_set_keymap(bufnr, "n", "P", "<cmd>lua print('Past requests')<cr>", { noremap = true })
  vim.api.nvim_buf_set_keymap(bufnr, "n", "C", "<cmd>lua print('Clearing requests')<cr>", { noremap = true })
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<cr>", "<cmd>lua Enter_event(" .. swapnr .. ")<cr>", { noremap = true })
end

return M
