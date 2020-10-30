
-- local tm = import("timer")
-- local removeTimer = tm.removeTimer
-- local setInterval = tm.setInterval
-- local setTimeout  = tm.setTimeout

-- local sformat = import("common").sformat

local round = import("common").round


------------------------------------------------------------
-- this
------------------------------------------------------------

this = this or {}

local cfg_offset = 1.2
local cfg_offset_cross = cfg_offset * 0.7

------------------------------------------------------------
-- func
------------------------------------------------------------


function getAroundPoints(inst)
  local x, y, z = inst.Transform:GetWorldPosition()
  local offset  = cfg_offset
  local offset2 = cfg_offset_cross

  -- if (TUNING) then
  --   TUNING.FL_GROUNDCREEP_TEST_RANGE_OFFSET = TUNING.FL_GROUNDCREEP_TEST_RANGE_OFFSET or offset
  --   offset = TUNING.FL_GROUNDCREEP_TEST_RANGE_OFFSET
  -- end

  local arr = {}
  table.insert(arr, {x, y, z})
  -- table.insert(arr, {x+offset, y, z})
  -- table.insert(arr, {x-offset, y, z})
  -- table.insert(arr, {x, y, z+offset})
  -- table.insert(arr, {x, y, z-offset})
  table.insert(arr, {x+offset2, y, z+offset2})
  table.insert(arr, {x+offset2, y, z-offset2})
  table.insert(arr, {x-offset2, y, z+offset2})
  table.insert(arr, {x-offset2, y, z-offset2})
  return arr
end


-- function GetTriggeredCreepSpawners(inst)
--   local arr = getAroundPoints(inst)
--   for i, pos in ipairs(arr) do
--     local x, y, z = unpack(pos)
--     local count = 0
--     for j, v in ipairs(TheWorld.GroundCreep:GetTriggeredCreepSpawners(x, y, z)) do
--       v:PushEvent("creepactivate", { target = inst })
--       count = count + 1
-- -- print(">>CreepSpawners point i=", i, j, v, count)
--     end
--     -- already
--     if (count > 0) then
--         return 
--     end
--   end
-- end

function OnCreep(inst)
  local arr = getAroundPoints(inst)
  for i, v in ipairs(arr) do
    local x, y, z = unpack(v)
    if (TheWorld.GroundCreep:OnCreep(x, y, z)) then
      return true
    end
  end
  return false
end

function UpdateGroundSpeedMultiplier(self)
xpcall(function ()
  local inst = self.inst
  local x, y, z = self.inst.Transform:GetWorldPosition()
  -- local b_onCreep = TheWorld.GroundCreep:OnCreep(x, y, z);
  local b_onCreep = OnCreep(inst)
  local oncreep = self.triggerscreep and b_onCreep

--   local arr = getAroundPoints(inst)
--   for i, v in ipairs(arr) do
--     local x, y, z = unpack(v)
--     local b_onCreep = TheWorld.GroundCreep:OnCreep(x, y, z)
-- print(100, i, "pos", round(x,0.01), round(z,0.01), "oncreep", b_onCreep)    
--   end

-- print(111, "pos", x, z, "oncreep", b_onCreep)
  if oncreep then
    -- if this ever needs to happen when self.enablegroundspeedmultiplier is set, need to move the check for self.enablegroundspeedmultiplier above
    if not self.wasoncreep then
        for i, v in ipairs(TheWorld.GroundCreep:GetTriggeredCreepSpawners(x, y, z)) do
            v:PushEvent("creepactivate", { target = self.inst })
-- print(222, i, v, "creepactivate", inst)
        end
        self.wasoncreep = true
    end

    -- if not self.wasoncreep then
    --     GetTriggeredCreepSpawners(inst)
    --     self.wasoncreep = true
    -- end
    self.groundspeedmultiplier = self.slowmultiplier
  else
--     for i, v in ipairs(TheWorld.GroundCreep:GetTriggeredCreepSpawners(x, y, z)) do
--         -- v:PushEvent("creepactivate", { target = self.inst })
-- print(33, i, v, "creepactivate fake", inst)
--     end
    self.wasoncreep = false

    local current_ground_tile = TheWorld.Map:GetTileAtPoint(x, 0, z)
    self.groundspeedmultiplier = (self:IsFasterOnGroundTile(current_ground_tile) or (self:FasterOnRoad() and ((RoadManager ~= nil and RoadManager:IsOnRoad(x, 0, z)) or current_ground_tile == GROUND.ROAD)))
              and self.fastmultiplier 
              or 1
  end
end, print)

end

------------------------------------------------------------
-- test
------------------------------------------------------------

return _M;