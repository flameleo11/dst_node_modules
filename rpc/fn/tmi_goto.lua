


return (function (_, prefab)

local code = [[


local function tmi_goto(prefab)
	if player.Physics ~= nil then
		player.Physics:Teleport(prefab.Transform:GetWorldPosition())
	else
		player.Transform:SetPosition(prefab.Transform:GetWorldPosition())
	end
end


local p = player
local t = p.components.talker

local target
local arr = {%q}
for k, v in pairs(arr) do
	target = c_findnext(v)
	if target then
		break
	end
end
if target == nil then
	player.components.talker:Say("No target!")
end

tmi_goto(target)

]]

	return code:format(prefab)
end)

