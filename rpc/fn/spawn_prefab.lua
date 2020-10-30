
return (function (cmd, prefab, userid, num)

local code = [[

local p = player
local t = p.components.talker

local prefab = %q
local inst = p

local ghost = SpawnAt(prefab, inst)
ghost.components.combat:SetTarget(target)

]]

  return (code):format(prefab)
end)


