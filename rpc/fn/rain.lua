
return (function (cmd, b)

local code = [[

local p = player
local t = p.components.talker
local b = %q
if (b == "1") then
  TheWorld:PushEvent("ms_forceprecipitation", true) 
else   
  TheWorld:PushEvent("ms_forceprecipitation", false) 
end

if (b == "frog") then
  TheWorld:PushEvent("ms_forceprecipitation", true)  
end



]]

  return (code):format(b or "1")
end)


