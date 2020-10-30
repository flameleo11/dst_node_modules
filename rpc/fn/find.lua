return (function (_, prefab, userid)
print(999, _, prefab)
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

local function tmi_goto(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	local pos = Point(x, y, z)
	if player.Physics ~= nil then
		player.Physics:Teleport(pos:Get())
	else
		player.Transform:SetPosition(pos:Get())
	end
end


local p = player
local t = p.components.talker

local target
local prefab = %q
local arr = {prefab}
for k, v in pairs(arr) do
	target = c_findnext(v)
	if target then
		break
	end
end
	print(111, ".............rpc.find target", target)


local userid=%q;
local p = UserToPlayer(userid);
if (p and p.prefab == prefab) then
	target = p 
	print(222, "...............rpc.find by userid", target, userid)
end

if target == nil then
	player.components.talker:Say("No target! 111")
	print(333, "...............rpc.find nil", target, userid)
	return 
end
print(3333, "rpc.find", target)
tmi_goto(target)

]]

	return code:format(prefab, userid or "")
end)



-- walrus
