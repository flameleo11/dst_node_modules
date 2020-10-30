
local tm = import("timer")
local removeTimer = tm.removeTimer
local setInterval = tm.setInterval
local setTimeout  = tm.setTimeout

local sformat = import("common").sformat

------------------------------------------------------------
-- this
------------------------------------------------------------

this = this or {}


------------------------------------------------------------
-- test
------------------------------------------------------------

function test_combat(self)
  local fn = _f(function ()
    if (self.inst and self.inst.userid == "KU__9qL15UL") then
      local combat = self
      local curtime = GetTime();
      local lasttime = combat.t_lasttime or 0
      print("[combat] 111 t_lasttime in aciton", curtime, lasttime, curtime-lasttime)

      combat.t_lasttime = curtime;    
    end
  end)
  fn()
end

function test_combat2(self)
  local fn = _f(function ()
    if (self.inst and self.inst.userid == "KU__9qL15UL") then
      local gametime = GetTime();
      local lastdoattacktime = self.lastdoattacktime or 0;
  print("[combat] 222 ", gametime, lastdoattacktime, gametime-lastdoattacktime)    
    end
  end)
  fn()
end

function test_combat2(self)
  local fn = _f(function ()
    if (self.inst and self.inst.userid == "KU__9qL15UL") then
      local gametime = GetTime();
      local lastdoattacktime = self.lastdoattacktime or 0;
  print("[combat] 222 ", gametime, lastdoattacktime, gametime-lastdoattacktime)    
    end
  end)
  fn()
end

function test_combat3(self)
  local fn = _f(function ()
    if (self.inst and self.inst.userid == "KU__9qL15UL") then
      local gametime = GetTime();
      local lastdoattacktime = self.lastdoattacktime or 0;
  print("[combat] 333 CanAttack", gametime, lastdoattacktime, gametime-lastdoattacktime)    
    end
  end)
  fn()
end

return _M;