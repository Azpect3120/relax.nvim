local window = require("relax.window")

local M = {}

--- Send a request to the given URL
--- @param url string: The URL to send the request to
--- @return string: The response from the server
function M.send_request(url)
  local command = "curl -s -w '\n' " .. url .. " | jq ."
  local handle = io.popen(command)
  if (handle == nil) then
    return 'could not run specified command:' .. command
  end

  local result = handle:read("*a")
  handle:close()
  return result
end

local function split_string(str)
  local lines = {}
  for line in string.gmatch(str, "[^\n]+") do
    table.insert(lines, line)
  end
  return lines
end

--- Create a new request buffer
--- @param swapnr number: The swap number of the window to create the buffer in
function M.new(swapnr)
  local bufnr = window.create_buffer("relaxrequest", true)
  window.update(bufnr, {
    "Relax REST Client",
    "",
    "Request: GET https://jsonplaceholder.typicode.com/posts/1",
    "",
    "Body:",
    "",
    "Response:",
  })

  vim.api.nvim_set_current_win(swapnr)
  vim.api.nvim_set_current_buf(bufnr)

  vim.api.nvim_create_autocmd("BufWriteCmd", {
    group = vim.api.nvim_create_augroup("relaxrequest", { clear = true }),
    pattern = "<buffer=" .. bufnr .. ">",
    desc = "Listening for changes in the Relax request buffer.",
    callback = function()
      local lines = M.send_request("GET https://jsonplaceholder.typicode.com/posts/1")
      window.append(bufnr, split_string(lines))
    end,
  })
end

return M
