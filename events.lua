local Emitter = import('Emitter')
local logger = import("log");
logger.log(_M._path, "import")

this = this or {}
this.emitter_list = this.emitter_list or {}


local events = setmetatable({}, {
	__call = function (_, name) 
		name = name or ""
		this.emitter_list[name] = this.emitter_list[name] or Emitter()
		return this.emitter_list[name]
	end
})



logger.log(_M._path, "end")
return events