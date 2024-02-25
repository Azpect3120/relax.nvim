local window = require("relax.window")
local keymaps = require("relax.keymaps")

local M = {
  bunfr = nil,
  winnr = nil,
  swapnr = nil
}

--- Setup the plugin
function M.setup()
  M.bufnr = window.create_buffer("relaxui", false)
end

--- Display the UI
function M.display()
  if (M.bufnr == nil) then
    M.setup()
  end
  M.swapnr = vim.api.nvim_get_current_win()
  M.winnr = window.create_split(M.bufnr)

  window.update(M.bufnr, { "Relax REST Client", "", "~ New Request     [N]", "~ Past Requests   [P]", "~ Clear Requests  [C]" })
  keymaps.setUIMappings(M.bufnr, M.swapnr)
end

return M
