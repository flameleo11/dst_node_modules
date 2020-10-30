
-- local tm = import("timer")
-- local removeTimer = tm.removeTimer
-- local setInterval = tm.setInterval
-- local setTimeout  = tm.setTimeout

-- local sformat = import("common").sformat

local PLAYER_COMBAT_COOLDOWN = 0.37
-- PLAYER_COMBAT_COOLDOWN = 0.5

------------------------------------------------------------
-- this
------------------------------------------------------------

this = this or {}




------------------------------------------------------------
-- test
------------------------------------------------------------
-- node_modules/my_scripts/combat.lua
-- min_attack_period
-- todo diff user cancel and auto script
function check_player_combat(self)
-- print("[test]", self.inst, self.inst and self.inst.userid)    
  if not (self.inst and self.inst.userid) then
    return true
  end

  local cd = PLAYER_COMBAT_COOLDOWN;
  self.fl_doattack_lasttime = self.fl_doattack_lasttime or 0

  local curtime = GetTime();
  local lasttime = self.fl_doattack_lasttime or 0
-- print("[test]", curtime, lasttime, curtime - lasttime, cd, (curtime - lasttime > cd))    

  if (curtime - lasttime > cd) then
    self.fl_doattack_lasttime = curtime
    return true
  end
  return false
end

return _M;