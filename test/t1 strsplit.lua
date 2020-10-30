require "tprint"
local push = table.insert
local tjoin = table.concat

function strsplit(str, delimiter)
  local pattern = ("[^%s]+"):format(delimiter)
  local arr = {}
  for seg in str:gmatch(pattern) do
    push(arr, seg)
  end
  return arr
end


local code = [[
An important point - solutions which use gmatch to drop the delimiter do NOT match empty strings between two newlines, so if you want to preserve these like a normal split implementation (for example, to compare lines across two documents) you are better off matching the delimiter such as in this example:

function string:split(delimiter)
  local result = { }
  local from  = 1
  local delim_from, delim_to = string.find( self, delimiter, from  )
  while delim_from do
    table.insert( result, string.sub( self, from , delim_from-1 ) )
    from  = delim_to + 1
    delim_from, delim_to = string.find( self, delimiter, from  )
  end
  table.insert( result, string.sub( self, from  ) )
  return result
end
]]


local arr = strsplit(code, '\n')

tprint(arr)