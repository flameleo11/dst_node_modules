
	-- return ("(%q)"):format(userid);
return (function (cmd, userid)

local code = [[
local p = player
local t = p.components.talker

TheWorld:PushEvent("ms_playerdespawnanddelete", player)
-- t:Say(godmode and "My wait is over." or "I shall not fear.")
]]

	return (code)
end)