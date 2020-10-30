
local logger = import("log");



------------------------------------------------------------
-- rem
------------------------------------------------------------


local mp = require "MessagePack"

local base64 = import("common/base64")
local base64_enc = base64.encode
local base64_dec = base64.decode

function encode(data)
  local buf = mp.pack(data)
  return base64_enc(buf)
end

function decode(str)
  local buf = base64_dec(str)
  local data = mp.unpack(buf)
  return data
end


logger.log(_M._path, "common.mp64 init", _M)


return _M