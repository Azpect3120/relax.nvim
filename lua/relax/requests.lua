local window = require("relax.window")
local util = require("relax.util")
local history = require("relax.history")

local M = {}

--- Send a request to the given URL
--- @param url string: The URL to send the request to
--- @param method string: The HTTP method to use
--- @param body string: The body of the request
--- @return string: The response from the server
function M.send_request(method, url, body)
  local command = ""
  if (body ~= nil) then
    command = "curl -s -w '\n' -X " ..
    method .. "-H 'Content-Type: application/json' -d '" .. body .. "' " .. url .. " | jq ."
  else
    command = "curl -s -w '\n' -X " .. method .. " " .. url .. " | jq ."
  end

  local handle = io.popen(command)
  if (handle == nil) then
    return 'could not run specified command:' .. command
  end

  local result = handle:read("*a")
  handle:close()
  return result
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
      -- Get the request buffer lines
      local req_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

      -- Parse the request
      local parsed = util.parse_request_buffer(req_lines)

      -- Add to history
      history.append(parsed.method, parsed.url)

      -- Send the request and get the response
      local res_lines = M.send_request(parsed.method, parsed.url, parsed.body)

      -- Clear the previous response
      vim.api.nvim_buf_set_lines(bufnr, util.get_response_line(req_lines), -1, false, {})

      -- Append the new response
      window.append(bufnr, util.split_string(res_lines))

      print(history.get())
    end,
  })
end

function M.show_history ()
  local history = history.get()

  for _, request in ipairs(history) do
    print(request.method .. " " .. request.url)
  end
end

--- Clear the request history
function M.clear_history ()
  history.clear()
end

return M
