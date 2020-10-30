
-- only table index nil will into __index

local function Class(static)
	local self = static or {}
	local _methods = {}

	local cls = {
		_static  = self;
		_methods = _methods;
	}

	local meta_cls = {
		__index = self;
		__newindex = _methods;
		__call = function (cls, ...)
			local obj = {}
			local meta_obj = {
				__index = function (t, k)
					local value = _methods[k]
					local t_value = type(value)
					if (t_value == "function") then
						return function (...)
							return value(obj, ...)
						end
					end
				end
			}
			setmetatable(obj, meta_obj)
			local init_fn = obj.new or obj.init;
			assert(init_fn, "Must implement constructor: Class.new or Class.init ")
			init_fn(...)
			return obj
		end
	}
	return setmetatable(cls, meta_cls)
end

return Class