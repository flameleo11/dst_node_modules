



return (function ()

local code = [[
local function find_near_pos(pos, min, max)
  max = math.max(min, max or min)
  local range = math.random(min, max)
  local clock_num = math.random(1, 12)
  local rx = math.ceil(range * math.cos(math.deg(clock_num*30)))
  local rz = math.ceil(range * math.sin(math.deg(clock_num*30)))

  pos.x = pos.x + rx
  pos.z = pos.z + rz
  return pos
end

local p = player
local t = p.components.talker

-- local x, y, z = p.Transform:GetWorldPosition()
-- local inst = SpawnPrefab("pond", "pond", nil, "KU__9qL15UL")
-- inst.Transform:SetPosition(x, y, z)

local pond = SpawnAt("pond", p)
local mypos = p:GetPosition();
local pos = find_near_pos(p:GetPosition(), 4)


-- print(111, mypos, pos)
-- print(222, mypos:Get(), pos:Get())
-- -- p:SetPosition(pos)
p.Transform:SetPosition(pos:Get())

t:Say("Fresh, cool ale here!")

]]

	return (code)
end)