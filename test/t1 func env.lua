
local x = 10

function test(i)
  local env = getfenv(i)
  print(i, env, x)
end

test()
for i=0,3 do
  test(i)
end

local t = {x=20, __index=_G}
setmetatable(t, t)

print(111, t)

local f = loadfile( "t2.lua")
setfenv(f, t)
f()


nil table: 0x564dfb12b900 10
0 table: 0x564dfb12b900 10
1 table: 0x564dfb12b900 10
2 table: 0x564dfb12b900 10
3 table: 0x564dfb12b900 10
111 table: 0x564dfb135b60
nil table: 0x564dfb135b60 20
0 table: 0x564dfb12b900 20
1 table: 0x564dfb135b60 20
2 table: 0x564dfb135b60 20
3 table: 0x564dfb12b900 20
222 table: 0x564dfb134e70
nil table: 0x564dfb134e70 30
0 table: 0x564dfb12b900 30
1 table: 0x564dfb134e70 30
2 table: 0x564dfb134e70 30
3 table: 0x564dfb135b60 30
[Finished in 0.0s]



-- f(1)
-- nil table: 0x558994854900 10
-- 0 table: 0x558994854900 10
-- 1 table: 0x558994854900 10
-- 2 table: 0x558994854900 10
-- 3 table: 0x558994854900 10
-- 111 table: 0x55899485eb60
-- nil table: 0x55899485eb60 20
-- 0 table: 0x558994854900 20
-- 1 table: 0x55899485eb60 20
-- 2 table: 0x55899485eb60 20
-- 3 table: 0x558994854900 20
-- [Finished in 0.0s]


--[[

111 nil table: 0x55f52ee9c900
111 1 table: 0x55f52ee9c900
111 2 table: 0x55f52ee9c900
111 3 table: 0x55f52ee9c900

  local fn = _loadfile(path)
  if not (fn and type(fn) == "function") then
    _err("import path", path, fn) 
  end

  local args = {...}
  args.n = #args
  args[0] = modname;

  local env = package._cache[modname]
  if (not env) then
    env = setmetatable({}, mt) 
  end

  env._err = _err;
  env._f = _f;
  env._path = path;
  env._M = env;
  env.arg = args;
  env_set_alias(env)

  setfenv(fn, env)
  local ret = {fn()}
  env._ret = ret;
  package._cache[modname] = env

]]