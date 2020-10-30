 ["hide"] = function (_, bFromLookat)
      local code = [[
local p = player
local t = p.components.talker
local inst = player
local bFromLookat = %s
if (bFromLookat) then
  local arr = TheWorld.arr_lookat or {}
  inst = arr[#arr]
end
if not (inst) then
  return 
end

function toggle_components(inst, name, enable)
  inst.components_bak = inst.components_bak or {}

  local disable = not enable
  if (disable) then
    if inst.components[name] then
      inst.components_bak[name] = inst.components_bak[name] or inst.components[name]
      inst:RemoveComponent(name)
      inst.components[name] = nil 
    end
  else
    if inst.components_bak[name] then
      inst:AddComponent(name)
      inst.components[name] = inst.components_bak[name];
    end
  end
end

function toggle_component_by_field(inst, name, field, enable, default)
  local self = inst.components[name]
  if not (self) then
    return 
  end

  inst.components_bak = inst.components_bak or {}
  local disable = not enable
  if (disable) then
    local data = self[field] and true or false
    inst.components_bak[name] = inst.components_bak[name] or {};
    inst.components_bak[name][field] = {data = data} 
    self[field] = default or false;
  else
    if inst.components_bak[name] and inst.components_bak[name][field] then
      self[field] = inst.components_bak[name][field].data
    end
  end  
end


local colours = {inst.AnimState:GetMultColour()}
local visable = (colours[1] ~= 0 
              or colours[2] ~= 0 
              or colours[3] ~= 0 
              or colours[4] ~= 0);

print("server start hiding:", visable, colours[1], colours[2], colours[3], colours[4])
inst.components_bak = inst.components_bak or {}

if (visable) then
  inst:AddTag("noplayerindicator")
  inst:AddTag("hiding")
  inst:AddTag("notarget")
  inst:AddTag("ignoretalking")
  inst:RemoveTag("inspectable")
  inst:RemoveTag("player")
  inst.inlimbo = true  
  inst.AnimState:SetMultColour(0,0,0,0)

  if (inst.DynamicShadow) then
    inst.DynamicShadow:Enable(false) 
  end
  if (inst.MiniMapEntity) then
    inst.MiniMapEntity:SetEnabled(false)
  end

  -- toggle_components(inst, "globalposition", false)
  toggle_components(inst, "inspectable", false)

  inst:Hide()
  print("[hide] hide myself :", inst, inst.components.inspectable, inst.components.globalposition)

  t:Say("I walk in the shadow")
else
  inst:RemoveTag("noplayerindicator")
  inst:RemoveTag("hiding")
  inst:RemoveTag("notarget")
  

  inst:RemoveTag("ignoretalking")
  inst:AddTag("inspectable")
  inst:AddTag("player")
  
  inst.inlimbo = false    
  inst.AnimState:SetMultColour(1,1,1,1)

  if (inst.DynamicShadow) then
    inst.DynamicShadow:Enable(true) 
  end
  if (inst.MiniMapEntity) then
    inst.MiniMapEntity:SetEnabled(true) 
  end

  -- toggle_components(inst, "globalposition", true)
  toggle_components(inst, "inspectable", true)

  inst:Show()
  t:Say("Light, guide my path.")
end

local colours = {inst.AnimState:GetMultColour()}
local visable = (colours[1] ~= 0 
              or colours[2] ~= 0 
              or colours[3] ~= 0 
              or colours[4] ~= 0);

print("server now hiding:", visable, inst:HasTag("hiding"))
print(colours[1], colours[2], colours[3], colours[4])

]]

      return code:format(bFromLookat and "true" or "false");
    end,
