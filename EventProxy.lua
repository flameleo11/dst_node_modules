local Emitter = import('Emitter')
local events = import('events')
local push = table.insert

local logger = import("log");
logger.log(_M._path, "import")


local EventProxy = {}

setmetatable(EventProxy, {
    __call = function (_, ...) 
        return EventProxy.new(...) 
    end
})

function EventProxy.new()
  local obj = {}
  local meta_obj = {
    __index = function (t, k)
      local v = EventProxy[k]
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
  logger.log(_M._path, "new", obj)
  obj.init()
  return obj
end

function EventProxy.init(this)
	this.arr_off_fn = {}
  logger.log(_M._path, "init", #this.arr_off_fn)
end

function EventProxy.createfn(this, name)
	local em = events(name);
	local fn_on = function (...)
    local arr = this.arr_off_fn
		local args = {...}
		local fn_off = function ()
			em.off(unpack(args))
		end
		push(this.arr_off_fn, fn_off)
    local t = {}
    push(t, fn_off)
    logger.log(_M._path, "createfn-->add. call(...)", #this.arr_off_fn, this.arr_off_fn, arr == this.arr_off_fn, arr, #arr, "t", t, #t)
		em.on(...)
	end
	return fn_on
end

function EventProxy.reset(this)
	local arr = this.arr_off_fn
	for i, fn in ipairs(this.arr_off_fn) do
		fn()
	end
  logger.log(_M._path, "reset before", #this.arr_off_fn, this.arr_off_fn)
  this.arr_off_fn = {}
  logger.log(_M._path, "reset after", #this.arr_off_fn, this.arr_off_fn)
end


logger.log(_M._path, "end")
return EventProxy