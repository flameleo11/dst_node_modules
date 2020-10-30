------------------------------------------------------------
-- base
------------------------------------------------------------

local push = table.insert
local tjoin = table.concat

local print = trace;
local eventmgr = import("events")()

local logger = import("log");
logger.log(_M._path, "import")
------------------------------------------------------------
-- this
------------------------------------------------------------

this = this or {}

this.inst = this.inst or nil
this.arr_register = this.arr_register or {}
this.arr_session  = this.arr_session or {}

------------------------------------------------------------
-- api
------------------------------------------------------------

function _removeTimer(timer)
  if (timer) then
    timer:Cancel()
  end
end

this.setTimeout = function (fn, interval)
  local inst = this.inst
  assert(inst, "setTimeout inst is nil")
  local elapse_time = 0
  local delay_sec = interval
  local timer = inst:DoTaskInTime(delay_sec, _f(function ()
    elapse_time = elapse_time + interval
    fn(elapse_time)
  end), 0)  
  return timer
end

this.setInterval = function (fn, interval)
  local elapse_time = 0
  local delay_sec = interval
  local timer = this.inst:DoPeriodicTask(interval, _f(function ()
    fn(elapse_time)
    elapse_time = elapse_time + interval
  end), 0)  
  return timer
end


------------------------------------------------------------
-- timer reg
------------------------------------------------------------

function createfn(name)
  logger.log(_M._path, "createfn", name)
  local caller = this[name]
  if not (type(caller) == "function") then
    return 
  end

  return function (...)
    logger.log(_M._path, "api", name)
    local id = #this.arr_session + 1
    local session = {
      enable = true;
      name   = name;
      caller = caller;
      params = {...};
      timer  = nil;
    }
    this.arr_session[id] = session;

    logger.log(_M._path, "api.fn start id", name, id)
    local params = {...}
    local fn = _f(function ()
      logger.log(_M._path, "api.fn running id ", name, id)

      if not (this.inst) then
        t_ls(session.params)
        logger.log(_M._path, "api.fn lost id ", name, id)
        trace("lost timer:", id, session)
        return  
      end
      if (session.enable) then
        logger.log(_M._path, "api.fn caller id ", name, id)
        session.timer = caller(unpack(params))
      end
    end)
    logger.log(_M._path, "api.fn end id", name, id)


    if (this.inst) then
      fn() 
    else
      push(this.arr_register, fn)
    end
    return id;
  end
end

setTimeout = createfn("setTimeout");
setInterval = createfn("setInterval");
removeTimer = function (id)
  local session = this.arr_session[id]
  if not (session) then
    return 
  end
  session.enable = false
  _removeTimer(session.timer)
end

function init(inst)
  logger.log(_M._path, "init() inst is ", inst)
  assert(inst, "timer inst is nil")
  this.inst = inst
  for i, fn in ipairs(this.arr_register) do
    fn()
  end
  this.arr_register = {}
end

function debug()
  print("inst", this.inst)
  for i, fn in ipairs(this.arr_register) do
    fn()
  end

  for i, fn in ipairs(this.arr_session) do
    fn()
  end

  this.arr_register = {}
end

logger.log(_M._path, "end")
return _M
