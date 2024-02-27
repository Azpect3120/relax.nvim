local window = require("relax.window")
local util = require("relax.util")
local history = require("relax.history")

local M = {
  history_displaying = false,
  request_bufnr = nil,
}

--- Send a request to the given URL
--- @param url string: The URL to send the request to
--- @param method string: The HTTP method to use
--- @param body string: The body of the request
--- @return string: The response from the server
function M.send_request(method, url, body)
  local command = ""
  if (body ~= nil) then
    command = "curl -s -w '\n' -X " ..
        method .. " -H 'Content-Type: application/json' -d '" .. body .. "' " .. url .. " | jq ."
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
  if M.request_bufnr then
    vim.api.nvim_set_current_win(swapnr)
    vim.api.nvim_set_current_buf(M.request_bufnr)
    window.update(M.request_bufnr,
      {
        "Relax REST Client",
        "",
        "Request: GET https://jsonplaceholder.typicode.com/posts/1",
        "",
        "Body:",
        "",
        "Response:",
      })
  else
    M.request_bufnr = window.create_buffer("relaxrequest", true)
    window.update(M.request_bufnr,
      { "Relax REST Client", "", "Request: GET https://jsonplaceholder.typicode.com/posts/1", "", "Body:", "",
        "Response:" })

    vim.api.nvim_set_current_win(swapnr)
    vim.api.nvim_set_current_buf(M.request_bufnr)
  end

  -- Create writing auto command for sending the request
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    group = vim.api.nvim_create_augroup("relaxrequest", { clear = true }),
    pattern = "<buffer=" .. M.request_bufnr .. ">",
    desc = "Listening for changes in the Relax request buffer.",
    callback = function()
      -- Get the request buffer lines
      local req_lines = vim.api.nvim_buf_get_lines(M.request_bufnr, 0, -1, false)

      -- Parse the request
      local parsed = util.parse_request_buffer(req_lines)

      -- Add to history
      history.append(parsed.method, parsed.url, parsed.body)

      -- Write history to file
      history.write(history.get())

      -- Send the request and get the response
      local res_lines = M.send_request(parsed.method, parsed.url, parsed.body)

      -- Clear the previous response
      vim.api.nvim_buf_set_lines(M.request_bufnr, util.get_response_line(req_lines), -1, false, {})

      -- Append the new response
      window.append(M.request_bufnr, util.split_string(res_lines))
    end,
  })
end

--- Load a request from the history
--- @param swapnr number: The swap number of the window to create the buffer in
--- @param history_index number: The index of the history to load
function M.load(swapnr, history_index)
  local his = history.get()[history_index]

  if M.request_bufnr then
    vim.api.nvim_set_current_win(swapnr)
    vim.api.nvim_set_current_buf(M.request_bufnr)
    window.update(M.request_bufnr, {
      "Relax REST Client",
      "",
      "Request: " .. his.method .. " " .. his.url,
      "",
      "Body: ",
    })
    for _, line in ipairs(util.split_string(his.body)) do
      window.append(M.request_bufnr, { line })
    end
    window.append(M.request_bufnr, {
      "",
      "Response:",
    })
  else
    M.request_bufnr = window.create_buffer("relaxrequest", true)
    window.update(M.request_bufnr, {
      "Relax REST Client",
      "",
      "Request: " .. his.method .. " " .. his.url,
      "",
      "Body: ",
    })
    for _, line in ipairs(util.split_string(his.body)) do
      window.append(M.request_bufnr, { line })
    end
    window.append(M.request_bufnr, {
      "",
      "Response:",
    })

    vim.api.nvim_set_current_win(swapnr)
    vim.api.nvim_set_current_buf(M.request_bufnr)
  end

  -- Create writing auto command for sending the request
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    group = vim.api.nvim_create_augroup("relaxrequest", { clear = true }),
    pattern = "<buffer=" .. M.request_bufnr .. ">",
    desc = "Listening for changes in the Relax request buffer.",
    callback = function()
      -- Get the request buffer lines
      local req_lines = vim.api.nvim_buf_get_lines(M.request_bufnr, 0, -1, false)

      -- Parse the request
      local parsed = util.parse_request_buffer(req_lines)

      -- Add to history
      history.append(parsed.method, parsed.url, parsed.body)

      -- Send the request and get the response
      local res_lines = M.send_request(parsed.method, parsed.url, parsed.body)

      -- Clear the previous response
      vim.api.nvim_buf_set_lines(M.request_bufnr, util.get_response_line(req_lines), -1, false, {})

      -- Append the new response
      window.append(M.request_bufnr, util.split_string(res_lines))
    end,
  })
end

--- Show the request history in the UI
--- @param bufnr number: The buffer number of the UI
function M.show_history(bufnr)
  if not M.history_displaying then
    local his = history.get()

    window.update(bufnr, { "Relax REST Client", "", "~ New Request     [N]", "⌄ Past Requests   [P]" })

    for _, h in ipairs(his) do
      window.append(bufnr, { " >> " .. h.method .. " " .. h.url })
    end
    window.append(bufnr, { "~ Clear Requests  [C]" })
    M.history_displaying = true
  else
    window.update(bufnr,
      { "Relax REST Client", "", "~ New Request     [N]", "~ Past Requests   [P]", "~ Clear Requests  [C]" })
    M.history_displaying = false
  end
end

--- Clear the request history
--- @param bufnr number: The buffer number of the UI
function M.clear_history(bufnr)
  history.clear()
  window.update(bufnr, { "Relax REST Client", "", "~ New Request     [N]", "~ Past Requests   [P]", "~ Clear Requests  [C]" })
  M.history_displaying = false
end

return M
