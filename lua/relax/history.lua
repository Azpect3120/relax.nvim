local Path = require("plenary.path")

local M = {
  history = {},
  max = 10
}

--- Append a request to the history
--- @param method string HTTP method
--- @param url string URL
--- @param body string Request body
function M.append(method, url, body)
  if #M.history >= M.max then
    table.remove(M.history, #M.history)
  end
  table.insert(M.history, 1, { method = method, url = url, body = body })
end

--- Set the history
--- @param history table | nil Request history
function M.set(history)
  if history then
    M.history = history
  end
end

--- Clear the history
function M.clear()
  M.history = {}
end

--- Get the history
--- @return table Request history
function M.get()
  return M.history
end

--- Write the history to the data file
--- @param history table Configuration to write
function M.write(history)
  local data_path = Path:new(string.format("%s/relax.json", vim.fn.stdpath("data")))
  data_path:write(vim.json.encode(history), "w")
end

--- Read the history from the data file
--- @return table | nil Request history
function M.read()
  local data_path = Path:new(string.format("%s/relax.json", vim.fn.stdpath("data")))

  if not data_path:exists() then
    data_path:write(vim.json.encode({}), "w")
  end

  local out_data = data_path:read()

  if not out_data or out_data == "" then
    data_path:write(vim.json.encode({}), "w")
    out_data = data_path:read()
  end

  return vim.json.decode(out_data)
end

return M
