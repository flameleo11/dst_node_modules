------------------------------------------------------------
-- base
------------------------------------------------------------

local push = table.insert
local tjoin = table.concat

-- import("log").debug()
local logger = import("log");
local common = import("common")
local eventmgr = import("events")()

local tm = import("timer")
local removeTimer = tm.removeTimer
local setInterval = tm.setInterval
local setTimeout  = tm.setTimeout


local sformat = common.sformat


require "tprint"

local b_server = TheNet:IsDedicated()

------------------------------------------------------------
-- this
------------------------------------------------------------

this = this or {}

function log(...)
  logger.log(_M._path, ...)
end



------------------------------------------------------------
-- config
------------------------------------------------------------

function GetExternalSpeedMutliplier(inst)
  if (TheNet:IsDedicated()) then
    return inst.components.locomotor.externalspeedmultiplier
  end
  -- todo
  -- ClientExternalSpeedMultiplier(inst)
  return 1
end



------------------------------------------------------------
-- func
------------------------------------------------------------

function GetSpeedFactor(inst)
  local mult = GetExternalSpeedMutliplier(inst)
  local arr = {}
  local inventory = inst.replica.inventory
  if inventory ~= nil then
    local rider = inst.replica.rider
    if rider ~= nil and rider:IsRiding() then
      local saddle = rider:GetSaddle()
      local inventoryitem = saddle ~= nil and saddle.replica.inventoryitem or nil
      if inventoryitem ~= nil then
        mult = mult * inventoryitem:GetWalkSpeedMult()
        -- from_name
        push(arr, {
          item = saddle,
          name = saddle.prefab,
          factor = inventoryitem:GetWalkSpeedMult()
        })
        -- print(111, saddle, inventoryitem:GetWalkSpeedMult())
      end
    else
      for k, v in pairs(inventory:GetEquips()) do
        local inventoryitem = v.replica.inventoryitem

        if inventoryitem ~= nil then
          -- print(222, mult, k, v.prefab, inventoryitem:GetWalkSpeedMult())
          mult = mult * inventoryitem:GetWalkSpeedMult()
          if not (inventoryitem:GetWalkSpeedMult() == 1) then
            push(arr, {
              item = v,
              name = v.prefab,
              factor = inventoryitem:GetWalkSpeedMult()
            })
          end
        end
      end
    end
  end
  -- return mult * (self:TempGroundSpeedMultiplier() or self.groundspeedmultiplier) * self.throttle
  -- without terrain tile effect
  return mult, arr
end

function GetRunSpeedWithMount(inst)
  local rider = inst.replica.rider
  local mount = rider ~= nil and rider:IsRiding() and rider:GetMount() or nil
  local runspeed = inst.player_classified ~= nil
    and inst.player_classified.runspeed:value()
    or 0;
  if (mount) then
    runspeed = rider:GetMountRunSpeed()
  end
  return runspeed, mount
end

function calcIncPctString(mult)
  local value = (mult-1)*100
  local pct = tostring(value) .. "%"
  if (value > 0) then
    pct = "+"..pct
  end
  return pct
end

function concatSpeedupItemsInfo(items)
  local arr = {}
  for i, v in ipairs(items) do
    local str = sformat("${name} ${inc}", {
      name = v.name;
      inc = calcIncPctString(v.factor);
    })
    push(arr, str)
  end
  return tjoin(arr, "\n")
end



function GetRunSpeedInfo(inst)
  local runspeed, mount = GetRunSpeedWithMount(inst)
  local mult, items = GetSpeedFactor(inst)

  local ms = runspeed * mult

  local p = inst
  local t = p.components.talker
  local x, y, z = p.Transform:GetWorldPosition()
  local rota = p:GetRotation()

  local pos = ("(%d, %d)"):format(x, z)
  local angle = ("%d°"):format(rota+90)
  -- local dist = 20
  -- local p1 = get_inst_front_pos(inst, dist)
  -- local p2 = get_inst_backward_pos(inst, dist)
  -- local pos1 = ("(%d, %d)"):format(p1.x, p1.z)
  -- local pos2 = ("(%d, %d)"):format(p2.x, p2.z)

  -- t:Say(pos)

  local name = mount
    and (mount.prefab or "mount (unknow)")
    or (p.prefab or "role (unknow)")

  local str = [[
speed: ${speed} ${speedup}

${name}: ${runspeed}
${items}
${pos} facing ${angle} 
]]
-- ${pos1} 
-- ${pos2} 

  -- if (b_debug) then
  --   str = str.. "fade_time: ${fade_time}"
  -- end
  local speedup = (mult ==1) and "" or calcIncPctString(mult);
  local info = sformat(str, {
      name = name;
      runspeed = runspeed;
      items = concatSpeedupItemsInfo(items);
      speedup = speedup;
      speed = ms;
      pos = pos;
      -- pos1 = pos1;
      -- pos2 = pos2;

      angle = angle;
      fade_time = this.fade_time;
    })


  return info;
end

return _M
