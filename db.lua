
local logger = import("log");
local common = reload("common")

local mp = require "MessagePack"
local filename = "./data/client.dat"
if (TheNet:IsDedicated()) then
	filename = "./data/server.dat" 
end

local enc = common.base64_encode
local dec = common.base64_decode
local delimiter = "\n"


local db = _M

this = this or {}

if (io.type(this.stdout) == "file") then
  this.stdout:close()
end
this.stdout = nil


if not (this.mt_null) then
  local mt = {
    __tostring = function ()
      return "null";
    end
  }
  this.mt_null = mt 
end

------------------------------------------------------------
-- func
------------------------------------------------------------

function enc_pack(data)
	local buf = mp.pack(data)
	return enc(buf)
end

function dec_unpack(buf)
	local buf = dec(str)
	local data = mp.unpack(buf)
	return data
end

function create_null_obj()
  return setmetatable({ _value = "null" }, this.mt_null)
end

function send_event(event, ...)
  local arr = {event, ...}
  local count = #arr
  local arr_nil = {}
  for i=1, count do
    if (arr[i] == nil) then
      arr[i] = create_null_obj()
      push(arr_nil, i)
    end
  end

  print("[warning] dst event emit nil:", event, tjoin(arr_nil, ","))
  for i, v in ipairs(arr) do
    print(i, type(v), v)
  end

  print("send:", count)
  send(arr)
end

function send(data)
	local f = init()
	local str = enc_pack(data)
	f:write(str..delimiter)
	-- f:write(delimiter)
end

function send_str(data)
	local f = init()
	-- _f(function ()
	  -- local str = enc_pack(data)
	  local str = data
	  f:write(str)
	  -- f:write("\0")
	  -- f:write(" ")
	-- end)
end

function write_end()
	local f = init()
  f:write(delimiter)
end

function init()
	local f = this.stdout
	if not (io.type(f) == "file") then
	  f = io.open(filename, "w")
	  assert(f, "[error] db fs open failed")
		this.stdout = f
		logger.log(_M._path, "db open fs")
	end
	return f
end

init()
logger.log(_M._path, "db start bbb111", _M)


return _M;