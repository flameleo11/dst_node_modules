
return (function (cmd, prefab, userid, num)

local code = [[

local p = player
local t = p.components.talker

local userid = %q
local inst = p
if (#userid > 0) then
  inst = UserToPlayer(userid) 
end

if not (inst) then
  t:Say("Who do you want to ")
  return
end

local ghost = SpawnAt(prefab, inst)
ghost.components.combat:SetTarget(target)

]]

  return (code):format(userid)
end)


