return (function (cmd, userid, num)

local code = [[

local function addSanity(inst, delta)
    if inst and inst.components
      and inst.components.sanity 
    then
      inst.components.sanity:DoDelta(delta)
    end
end


local p = player
local t = p.components.talker

local num = tonumber(%s) or 0
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

if (num ~= 0) then
	addSanity(inst, num)
end

]]

	return (code):format(num, userid)
end)


