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

function load_fn(cmd, ...)
  local create_code_fn = reload("rpc/fn/"..cmd);
  return create_code_fn;
end

function send(cmd, ...)
  local code
  local args = {...}
  local create_code_fn = load_fn(cmd)
  if (create_code_fn) then
    code = create_code_fn(cmd, ...)
  end

  if not (code and #code > 0) then
  	print("[error] rpc cmd create code failed", cmd, create_code_fn, code)
  	return
  end

  exec(code)
end

function exec(code)
  local fn = loadstring(code);
  this.last_rpc_code = code
  if not (fn) then
      print("[error] rpc code syntax error:", cmd, code, fn)
      return 
  end
  TheNet:SendRPCToServer(RPC["MY_CONSOLE"], code) 
end

return _M
