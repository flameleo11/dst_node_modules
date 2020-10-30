
return (function (cmd, userid)

local code = [[

local p = player
local t = p.components.talker

local userid = %q
local inst = p
if (#userid > 0) then
  inst = UserToPlayer(userid) 
end

if not (inst) then
  t:Say("Who you want me to change")
  return
end

if not (inst.t_locked) then
  inst.t_locked = true
  inst.components.locomotor:SetExternalSpeedMultiplier(inst, "c_speedmult", 0)
else
  inst.t_locked = nil
  inst.components.locomotor:SetExternalSpeedMultiplier(inst, "c_speedmult", 1)
end

]]

  return (code):format(userid)
end)


