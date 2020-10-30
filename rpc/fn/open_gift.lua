return (function ()

local code = [[
local p = player
local t = p.components.talker
local g = p.components.giftreceiver

if g and g.giftcount > 0 then
	p:PushEvent("ms_opengift")
	t:Say("Thanks for this gift!")
else
	t:Say("The only gift I desire is a swift end...")
end
]]

	return (code)
end)


--[[

function open_gift(delay)
  delay = delay or 10
  rpc.send("open_gift")
  
  SendRPCToServer(RPC.OpenGift)

  removeTimer(this.tm_open_gift_end)
  this.tm_open_gift_end = setTimeout(function ()
    SendRPCToServer(RPC.DoneOpenGift)
  end, delay)
end
todotset
  -- rpc.send("closepopups")

 ThePlayer:PushEvent("ms_closepopups")
 inst:PushEvent("ms_closepopups")
    self.inst:PushEvent("ms_doneopengift", usewardrobe and { wardrobe = self.giftmachine } or nil)

function GiftReceiver:OnStopOpenGift(usewardrobe)
    self.inst:PushEvent("ms_doneopengift", usewardrobe and { wardrobe = self.giftmachine } or nil)
end

		if gift_count > 0  then
			inst:PushEvent("ms_opengift")
			inst:RemoveTag("Gift"..inst.giftcount)
			inst.giftcount=inst.giftcount+1
			inst:AddTag("Gift"..inst.giftcount)
			--print("????")

local eq = (g.inst == p)
t:Say(eq and "===" or "!==")

if giftreceiver ~= nil then
t:Say("giftreceiver is "..tostring(giftreceiver.OpenNextGift))
tprint(giftreceiver.OpenNextGift)
giftreceiver.inst:PushEvent("ms_opengift")
print(111, giftreceiver.giftcount )
else
t:Say("giftreceiver is "..tostring(giftreceiver))
end


if g then
	if g.giftcount > 0 then
		g.inst:PushEvent("ms_opengift")
	end
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