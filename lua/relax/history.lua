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
