return (function (_, userid, x, z)

local code = [[
local p = player
local t = p.components.talker

local userid = %q
local inst = p
if (#userid > 0) then
	inst = UserToPlayer(userid) 
end

print(333, userid, p, inst)

if not (inst) then
	t:Say("Who you want me change")
	return
end

local x = %d
local z = %d
p.Transform:SetPosition(x, 0, z)

]]

local suffix = [[
local pos = ("(%d, %d)"):format(x, z)
t:Say(pos)
]]
print(222, userid, x, z)
	local code = (code):format(userid or "", x, z)
	return code..suffix
end)



