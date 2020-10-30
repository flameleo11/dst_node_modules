return (function (_, userid, x, z)

local code = [[
local p = player
local t = p.components.talker

local userid = %q
local inst = UserToPlayer(userid)
if not (inst) then
	t:Say("Show me a target.")
	return
end

local rx = %d
local rz = %d
local x, y, z = inst.Transform:GetWorldPosition()
p.Transform:SetPosition(x+rx, 0, z+rz)
t:Say("I'm ready to track.")
]]

	return (code):format(userid, x, z)
end)



