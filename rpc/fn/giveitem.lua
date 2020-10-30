



return (function (_, prefab, count, userid)

local code = [[

local p = player
local t = p.components.talker

local prefab = string.lower(%q)
local count = %s

for i = 1, count or 1 do
  local inst = DebugSpawn(prefab)
  if inst ~= nil then
    print("giving ", inst)
    p.components.inventory:GiveItem(inst)
  end
end

t:Say("I've got it.")

]]

	return (code):format(prefab, count)
end)