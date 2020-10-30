------------------------------------------------------------
-- base
------------------------------------------------------------

local push = table.insert
local tjoin = table.concat

local print = trace;
local eventmgr = import("events")()

------------------------------------------------------------
-- header
------------------------------------------------------------

local _inst
local _arr_register = {}

------------------------------------------------------------
-- api
------------------------------------------------------------

function _setTimeout(fn, interval)
  local elapse_time = 0
  local delay_sec = interval
  local timer = inst:DoTaskInTime(delay_sec, _f(function ()
    elapse_time = elapse_time + interval
    fn(elapse_time)
  end), 0)  
  return timer
end

function _setInterval(fn, interval)
  local elapse_time = 0
  local delay_sec = interval
  local timer = inst:DoPeriodicTask(interval, _f(function ()
    fn(elapse_time)
    elapse_time = elapse_time + interval
  end), 0)  
  return timer
end


------------------------------------------------------------
-- timer reg
------------------------------------------------------------

function removeTimer(timer)
  if (timer) then
    timer:Cancel()
  end
end

function setTimeout(...)
  local params = {...}
  if (inst) then
    return _setTimeout(unpack(params))
  end

  push(_arr_register, function ()
    _setTimeout(unpack(params))
  end)
end

function setInterval(...)
  local params = {...}
  if (inst) then
    return _setInterval(unpack(params))
  end

  push(_arr_register, function ()
    _setInterval(unpack(params))
  end)
end

eventmgr.on('TheWorld', function (inst)
  _inst = inst
  for i, fn in ipairs(_arr_register) do
    fn()
  end
end)

return _M
