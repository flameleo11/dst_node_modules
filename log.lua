------------------------------------------------------------
-- base
------------------------------------------------------------

local push = table.insert
local tjoin = table.concat
local print = trace;

------------------------------------------------------------
-- this
------------------------------------------------------------

this = this or {}


------------------------------------------------------------
-- api
------------------------------------------------------------

function log(...)
  local arr = {}
  for i, v in ipairs({...}) do
    push(arr, tostring(v))
  end
  push(this, tjoin(arr, "|"))
end

function debug()
  t_ls(this)
end


return _M
