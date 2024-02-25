local M = {
  history = {}
}

--- Append a request to the history
--- @param method string HTTP method
--- @param url string URL
function M.append(method, url)
  table.insert(M.history, { method = method, url = url })
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

return M
