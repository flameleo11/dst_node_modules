local push = table.insert
local tjoin = table.concat

local pfx_once = '_once_'
local _none_name = ''
local Emitter = {}

local logger = import("log");

function log(...)
  logger.log(_M._path, ...)
end

setmetatable(Emitter, {
  __call = function (_) 
    return Emitter.new() 
  end
})

function Emitter.new()
  local obj = {}
  local meta_obj = {
    __index = function (t, k)
      local v = Emitter[k]
      if (type(v) == "function") then
        local warpper = function (...)
          return v(obj, ...)
        end
        return warpper;
      end
      return v
    end
  }
  setmetatable(obj, meta_obj)
  obj.init()
log("new Emitter obj")

  return obj
end

function Emitter.init(this)
  this._event_fn = {}
end

-- there is no need to add same
-- listener twice for same event
function Emitter.addListener(this, ...)
  local arr = {...}
  if not (type(arr[1]) == "string") then
    table.remove(arr, 1)  -- shift arry omit 1st param
  end
  local event, fn = unpack(arr)
log("event add", event, fn)  


  this._event_fn[event] = this._event_fn[event] or {}
  this._event_fn[event][fn] = true
end

function Emitter.enable(this, event, fn, enable)
  if (  this._event_fn[event] 
    and this._event_fn[event][fn] ~= nil) then
    this._event_fn[event][fn] = enable 
  end
end

function Emitter._once_name(this, event)
  return pfx_once..event;
end

function Emitter.once(this, event, fn)
  this.addListener(this._once_name(event), fn)
end

function Emitter._dispatch(this, event, ...)
  local fn_dict = this._event_fn[event];
  if not (fn_dict) then
    return 
  end
  

  -- for fn, enable in pairs(fn_dict) do
  --   if (enable) then
  --     xpcall(function ()
  --       fn(unpack(params))
  --     end, print)
  --   end
  -- end  

  -- support in fns call event api
  -- to change fn_dict 
  local arr = {}
  for fn, enable in pairs(fn_dict) do
    if (enable) then
      push(arr, fn)
    end
  end

  -- one of fns throw error 
  -- do not stop other emit
  local params = {...}
  for i, fn in ipairs(arr) do
    xpcall(function ()
      fn(unpack(params))
    end, print)
  end

end

function Emitter.emit(this, event, ...)
  event = event or _none_name
  this._dispatch(event, ...)

  -- local once_event = this._once_name(event)
  -- this._dispatch(once_event, ...)
  -- this._event_fn[once_event] = nil;
end

function Emitter.removeAllListeners(this, event)
  this._event_fn[event] = nil
  this._event_fn[this._once_name(event)] = nil
end

function Emitter._clear(this, event, fn)
  if (fn and this._event_fn[event]) then
    this._event_fn[event][fn] = false 
  end
end

function Emitter.removeListener(this, event, fn)
  this._clear(event, fn)
  this._clear(this._once_name(event), fn)
end

Emitter.on = Emitter.addListener
Emitter.off = Emitter.removeListener

log("Emitter end")  


return Emitter
