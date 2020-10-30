
StartThread = ThePlayer:StartThread(function()
	local qid = true
	local pos = GLOBAL.ThePlayer.zdpr
	while qid do
		local C = nil
		local beibao = GLOBAL.EQUIPSLOTS.BACK or GLOBAL.EQUIPSLOTS.BODY  --Shang
		local B = GLOBAL.ThePlayer.replica.inventory:GetEquippedItem(beibao)
		if B ~= nil then
			for i=1, 4 do
				if not B.replica.container:GetItemInSlot(i) then
					qid = false
					GLOBAL.ThePlayer.pzz:SetList(nil)
					GLOBAL.ThePlayer.pzz = nil
					return
				end
			end
		end


		--FindEntity definition
		-- function FindEntity(inst, radius, fn, musttags, canttags, mustoneoftags)
			-- if inst ~= nil and inst:IsValid() then
				-- local x, y, z = inst.Transform:GetWorldPosition()
				-- --print("FIND", inst, radius, musttags and #musttags or 0, canttags and #canttags or 0, mustoneoftags and #mustoneoftags or 0)
				-- local ents = TheSim:FindEntities(x, y, z, radius, musttags, canttags, mustoneoftags) -- or we could include a flag to the search?
				-- for i, v in ipairs(ents) do
					-- if v ~= inst and v.entity:IsVisible() and (fn == nil or fn(v, inst)) then
						-- return v
					-- end
				-- end
			-- end
		-- end

		if _G.ThePlayer.prefab ~= "warly" then -- if not warly then do the non warly routine
			C = GLOBAL.FindEntity(GLOBAL.ThePlayer,20,function(guy)
				return guy.replica and guy.replica.container and guy.prefab == "cookpot"
				and guy.replica.container:IsOpenedBy(GLOBAL.ThePlayer)
				and guy:GetDistanceSqToPoint(pos:Get()) < 14*14
				end,{ "structure" },{ "INLIMBO", "noauradamage" })

			if C ~= nil then
				ccc = 0.01
				local aa = 1
				local bb = 0
				local E = C ~= nil and C.replica.container:GetItemInSlot(aa)
				while B ~= nil and C ~= nil and not C.replica.container:IsFull() and bb < 100 and aa < 5
				and C.replica.container:IsOpenedBy(GLOBAL.ThePlayer) do
					bb = bb + 1
					if not C.replica.container:GetItemInSlot(aa) then
						B.replica.container:MoveItemFromAllOfSlot(aa,C)
					else
						aa = aa + 1
					end
					GLOBAL.Sleep(0.01)
				end
				if C and C.replica.container:IsOpenedBy(GLOBAL.ThePlayer) then
					GLOBAL.SendRPCToServer(GLOBAL.RPC.DoWidgetButtonAction, GLOBAL.ACTIONS.COOK.code, C, GLOBAL.ACTIONS.COOK.mod_name)
				end
			end

			if not C then
				C = GLOBAL.FindEntity(GLOBAL.ThePlayer,20,function(guy)
					return guy.replica and guy.replica.container and guy.prefab == "cookpot"
					and guy:GetDistanceSqToPoint(pos:Get()) < 14*14 and GLOBAL.ThePlayer.components.playeractionpicker:DoGetMouseActions(nil,guy)
					and (GLOBAL.ThePlayer.components.playeractionpicker:DoGetMouseActions(nil,guy).action == GLOBAL.ACTIONS.RUMMAGE
					or GLOBAL.ThePlayer.components.playeractionpicker:DoGetMouseActions(nil,guy).action == GLOBAL.ACTIONS.HARVEST)
					end,{ "structure" },{ "INLIMBO", "noauradamage" })

				if C ~= nil then
					ccc = 0.01
					local A = C:GetPosition()
					local controlmods = GLOBAL.ThePlayer.components.playercontroller:EncodeControlMods()
					local E,F = GLOBAL.ThePlayer.components.playeractionpicker:DoGetMouseActions(A, C)
					if E ~= nil then
						GLOBAL.SendRPCToServer(GLOBAL.RPC.LeftClick, E.action.code, A.x, A.z, C, false, controlmods, nil, E.action.mod_name)
						if E and E.action == GLOBAL.ACTIONS.RUMMAGE then
							ccc = 0.7
						end
					end
				end
			end
			GLOBAL.Sleep(ccc)
			else -- else warly so do the warly routine
			C = GLOBAL.FindEntity(GLOBAL.ThePlayer,20,function(guy)
				return guy.replica and guy.replica.container and (guy.prefab == "cookpot" or guy.prefab == "portablecookpot")
				and guy.replica.container:IsOpenedBy(GLOBAL.ThePlayer)
				and guy:GetDistanceSqToPoint(pos:Get()) < 14*14
				end,{ "structure" },{ "INLIMBO", "noauradamage" })

			if C ~= nil then
				ccc = 0.01
				local aa = 1
				local bb = 0
				local E = C ~= nil and C.replica.container:GetItemInSlot(aa)
				while B ~= nil and C ~= nil and not C.replica.container:IsFull() and bb < 100 and aa < 5
				and C.replica.container:IsOpenedBy(GLOBAL.ThePlayer) do
					bb = bb + 1
					if not C.replica.container:GetItemInSlot(aa) then
						B.replica.container:MoveItemFromAllOfSlot(aa,C)
					else
						aa = aa + 1
					end
					GLOBAL.Sleep(0.01)
				end
				if C and C.replica.container:IsOpenedBy(GLOBAL.ThePlayer) then
					GLOBAL.SendRPCToServer(GLOBAL.RPC.DoWidgetButtonAction, GLOBAL.ACTIONS.COOK.code, C, GLOBAL.ACTIONS.COOK.mod_name)
				end
			end

			if not C then
				C = GLOBAL.FindEntity(GLOBAL.ThePlayer,20,function(guy)
					return guy.replica and guy.replica.container and (guy.prefab == "cookpot" or guy.prefab == "portablecookpot")
					and guy:GetDistanceSqToPoint(pos:Get()) < 14*14 and GLOBAL.ThePlayer.components.playeractionpicker:DoGetMouseActions(nil,guy)
					and (GLOBAL.ThePlayer.components.playeractionpicker:DoGetMouseActions(nil,guy).action == GLOBAL.ACTIONS.RUMMAGE
					or GLOBAL.ThePlayer.components.playeractionpicker:DoGetMouseActions(nil,guy).action == GLOBAL.ACTIONS.HARVEST)
					end,{ "structure" },{ "INLIMBO", "noauradamage" })

				if C ~= nil then
					ccc = 0.01
					local A = C:GetPosition()
					local controlmods = GLOBAL.ThePlayer.components.playercontroller:EncodeControlMods()
					local E,F = GLOBAL.ThePlayer.components.playeractionpicker:DoGetMouseActions(A, C)
					if E ~= nil then
						GLOBAL.SendRPCToServer(GLOBAL.RPC.LeftClick, E.action.code, A.x, A.z, C, false, controlmods, nil, E.action.mod_name)
						if E and E.action == GLOBAL.ACTIONS.RUMMAGE then
							ccc = 0.7
						end
					end
				end
			end
			GLOBAL.Sleep(ccc)


		end --ends warly conditional if
	end --end while loop

end) --end startthread