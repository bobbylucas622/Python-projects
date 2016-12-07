#!/usr/bin/env lua
local l=""
while l do
  l = io.read()
  if l then
    l = l:gsub("^%s+"," ")
    l = l:gsub(";(.*)$","")
    if not (l:match("^[\t%s]*$")) then -- Ignore empty lines
      if l ~= "" then
        print(l)
      end
    end
  else
    --break
  end
end
