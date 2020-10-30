------------------------------------------------------------
-- base
------------------------------------------------------------

local push = table.insert
local tjoin = table.concat

local floor = math.floor
local mod = math.mod
local format = string.format

------------------------------------------------------------
-- this
------------------------------------------------------------

this = this or {}



------------------------------------------------------------
-- api
------------------------------------------------------------

function dhms(time)
  local days = floor(time/86400)
  local hours = floor(mod(time, 86400)/3600)
  local minutes = floor(mod(time,3600)/60)
  local seconds = floor(mod(time,60))
  return days, hours, minutes, seconds
end


function fmt_dhms(days, hours, minutes, seconds)
	local s1 = days > 0 and format("%d天",days) or ""
	local s2 = hours > 0 and format("%d小时",hours) or ""
	local s3 = minutes > 0 and format("%d分钟",minutes) or ""
	local s4 = seconds > 0 and format("%d秒",seconds) or ""
  return s1..s2..s3..s4
end


function clock_text(sec)
	sec = sec or 0
  return fmt_dhms(unpack{dhms(sec)})
end


return _M
