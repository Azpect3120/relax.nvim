local M = {}

--- Split a string into lines
--- @param str string: The string to split
--- @return table: The lines of the string
function M.split_string(str)
  local lines = {}
  for line in string.gmatch(str, "[^\n]+") do
    table.insert(lines, line)
  end
  return lines
end

--- Parse the new request buffer
--- @param lines table: The lines of the request buffer
--- @return table: The parsed request buffer
function M.parse_request_buffer(lines)
  local parsed = {
    method = nil,
    url = nil,
    body = nil,
  }

  local linenrs = {
    response = M.get_response_line(lines),
    body = -1,
  }

  for i, line in ipairs(lines) do
    if string.find(line, "Request:") then
      local method, url = line:match("Request: ([^ ]+) (.+)")
      if method and url then
        parsed.method = method
        parsed.url = url
      end
    elseif string.find(line, "Body:") then
      linenrs.body = i
    end
  end

  if linenrs.body > -1 then
    local body_string = ""
    for i = linenrs.body, linenrs.response - 1 do
      body_string = body_string .. lines[i] .. "\n"
    end

    local start_idx = body_string:find("{")
    if start_idx then
      parsed.body = body_string:sub(start_idx, -1)
      return parsed
    end
  end

  parsed.body = ""
  return parsed
end

--- Get the response line from the given lines
--- @param lines table: The lines to search for the response lines
--- @return number: The response line number
function M.get_response_line(lines)
  for i, line in ipairs(lines) do
    if string.find(line, "Response:") then
      return i
    end
  end
  return -1
end

return M
