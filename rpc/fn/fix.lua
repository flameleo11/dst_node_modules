return (function ()

local code = [[
local p = player
local t = p.components.talker

if p:HasTag("playerghost") then
	p:PushEvent("respawnfromghost")
	p.rezsource = STRINGS.NAMES.RESURRECTIONSTONE or "..."
else
	local h = p.components.health
	if h then
		local godmode = h.invincible
		t:Say(godmode and "My wait is over." or "I shall not fear.")
		print(godmode and "God Mode:禁用 Disabled" or "God Mode:启用 Enabled")
		h:SetInvincible(not godmode)
	end
end
]]

	return (code)
end)