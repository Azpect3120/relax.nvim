local requests = require("relax.requests")
local util = require("relax.util")

local M = {}

--- Function to handle the enter event in the window
--- @param swapnr number: The previous window number
--- @param bufnr number: The buffer number of the UI
function Enter_event(swapnr, bufnr)
  local line = vim.api.nvim_get_current_line()

  if (string.find(line, "New")) then
    requests.new(swapnr)
  elseif (string.find(line, "Past")) then
    requests.show_history(bufnr)
  elseif (string.find(line, "Clear")) then
    requests.clear_history(bufnr)
  else
    local ui_bufnr = vim.api.nvim_get_current_buf()
    local ui_lines = vim.api.nvim_buf_get_lines(ui_bufnr, 0, -1, false)

    local linenr = vim.api.nvim_win_get_cursor(0)[1]
    local pastnr = util.get_ui_request_line(ui_lines)

    local history_index = linenr - pastnr
    requests.load(swapnr, history_index)
  end
end

--- Keymap for new request
--- @param swapnr number: The previous window number
function New_request(swapnr)
  requests.new(swapnr)
end

--- Keymap for showing the history
--- @param bufnr number: The buffer number
function Show_history(bufnr)
  requests.show_history(bufnr)
end

--- Keymap for clearing the history
--- @param bufnr number: The buffer number
function Clear_history(bufnr)
  requests.clear_history(bufnr)
end

--- Set the key mappings for the window UI
--- @param bufnr number: The buffer number
--- @param swapnr number: The previous window number
function M.setUIMappings(bufnr, swapnr)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<cr>", "<cmd>lua Enter_event(" .. swapnr .. ", " .. bufnr .. ")<cr>", { noremap = true })
  vim.api.nvim_buf_set_keymap(bufnr, "n", "N", "<cmd>lua New_request(" .. swapnr .. ")<cr>", { noremap = true })
  vim.api.nvim_buf_set_keymap(bufnr, "n", "P", "<cmd>lua Show_history(" .. bufnr.. ")<cr>", { noremap = true })
  vim.api.nvim_buf_set_keymap(bufnr, "n", "C", "<cmd>lua Clear_history(" .. bufnr .. ")<cr>", { noremap = true })
end

return M
