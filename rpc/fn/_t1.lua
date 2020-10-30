
function send_gm_rpc(code, cmd, ...)
  -- todo add chatoutside
  -- type name easy
  local speedup = function (_, num)
    local code = ([[
TheSim:SetTimeScale(%s) 
print("Speed is now ", TheSim:GetTimeScale())
]]):format(num or "1")
    print(">>>>>>>>>>", code)
    return (code);
  end

  local dt = {
    ["test"] = function (_, b)
      local code = [[
local p = player
local t = p.components.talker      
local giftreceiver = player.components.giftreceiver
if giftreceiver ~= nil then
    t:Say("giftreceiver is "..tostring(giftreceiver.OpenNextGift))
    tprint(giftreceiver.OpenNextGift)
    giftreceiver.inst:PushEvent("ms_opengift")
    print(111, giftreceiver.giftcount )
else
    t:Say("giftreceiver is "..tostring(giftreceiver))
end
]]
      return code;
    end,    
    ["name"] = function (_, str)
      local code = ([[
local p = player
local b = p.components.builder
local t = p.components.talker
local str = %q
p.t_my_name = p.t_my_name or p.name
if (str and #str > 0) then
  p.name = str
else
  p.name = p.t_my_name
end 
t:Say("my name is "..p.name)
]]):format(str or "p.name")    
      return (code);
    end,    

    ["timeup"] = speedup,
    ["worldspeed"] = speedup,

    ["next"] = function (_, num)
      local code = ([[
-- step = 1
for i=1, %s do
  TheWorld:PushEvent("ms_nextphase")
end
]]):format(num or "1")
      return (code);
    end,
    ["skip"] = function (_, day)
      -- default c_skip() is 1 day
      return ("c_skip(%s)"):format(day or "");
    end,
    ["fix"] = function (_, userid)
      local code = [[
-- local inst = UserToPlayer(%q);
-- local multiplier = 1
-- inst.components.locomotor:SetExternalSpeedMultiplier(inst, "c_speedmult", multiplier)
local UserCommands = require("usercommands")
local VoteUtil = require("voteutil")

local p = player
local t = p.components.talker

AddUserCommand("regenerate", {
    prettyname = nil, --default to STRINGS.UI.BUILTINCOMMANDS.REGENERATE.PRETTYNAME
    desc = nil, --default to STRINGS.UI.BUILTINCOMMANDS.REGENERATE.DESC
    permission = COMMAND_PERMISSION.ADMIN,
    confirm = true,
    slash = true,
    usermenu = false,
    servermenu = true,
    params = {},
    vote = true,
    votetimeout = 30,
    voteminstartage = 1,
    voteminpasscount = 1,
    votecountvisible = true,
    voteallownotvoted = true,
    voteoptions = nil, --default to { "Yes", "No" }
    votetitlefmt = nil, --default to STRINGS.UI.BUILTINCOMMANDS.REGENERATE.VOTETITLEFMT
    votenamefmt = nil, --default to STRINGS.UI.BUILTINCOMMANDS.REGENERATE.VOTENAMEFMT
    votepassedfmt = nil, --default to STRINGS.UI.BUILTINCOMMANDS.REGENERATE.VOTEPASSEDFMT
    votecanstartfn = VoteUtil.DefaultCanStartVote,
    voteresultfn = VoteUtil.YesNoMajorityVote,
    serverfn = function(params, caller)
        --NOTE: must support nil caller for voting
        if caller ~= nil then
            --Wasn't a vote so we should send out an announcement manually
            --NOTE: the vote regenerate announcement is customized and still
            --      makes sense even when it wasn't a vote, (run by admin)
            local command = UserCommands.GetCommandFromName("regenerate")
            TheNet:AnnounceVoteResult(command.hash, nil, true)
        end
        TheWorld:DoTaskInTime(5, function(world)
            if world.ismastersim then
                -- fixed by me
                -- disable reset world
                -- TheNet:SendWorldResetRequestToServer()
            end
        end)
    end,
})

t:Say("That's it")


]]
      return code:format(userid)    
    end,

    ["speed"] = function (_, sz_num)
      local code = ([[
local inst = player;
local multiplier = %s
inst.components.locomotor:SetExternalSpeedMultiplier(inst, "c_speedmult", multiplier)
]])
      return code:format(sz_num or "1")
    end,
    ["despawn"] = function (_, mult)
      local code = [[
TheWorld:PushEvent("ms_playerdespawnanddelete", player)
]]
      return code;
    end,

    ["repick"] = function (_, name)
      return ('player.prefab = %q; print(player.prefab);'):format(name);
    end,
    ["restart"] = function ()
      return "c_regenerateworld()";
    end,
    ["reset"] = function ()
      return "c_reset()";
    end,
    ["save"] = function ()
      return "c_save()";
    end,
    ["rollback"] = function (_, day)
      return ("c_rollback(%s)"):format(day or "");
    end,
    ["roll"] = function (_, sides, dice)
      return ("TheNet:DiceRoll(%s, %s)"):format(sides, dice);
    end,
    ["kick"] = function (_, userid)
      return ("TheNet:Kick(%q)"):format(userid);
    end,
    -- system mesage
    ["SystemMessage"] = function (_, msg)
      return ([[TheNet:SystemMessage(%q)]]):format(msg);
    end,

    ["print_world_meta"] = function (_, mult)
      local code = [[
require "tprint"
tprint(TheWorld.meta)
]]
      return code;
    end,    
    ["ban"] = function (_, userid, time)
      -- todo test ban or BanForTime
      -- if params.seconds ~= nil then
      --     local seconds = tonumber(params.seconds)
      --     TheNet:BanForTime(clientid, seconds)
      -- else
      --     TheNet:Ban(clientid)
      -- end
      return ("TheNet:BanForTime(%q, %s)"):format(userid, time);
    end,
    ["empty_pack"] = function (_, flag)
      local code = [[
local flag = %d
local inventory = player and player.components.inventory or nil
local backpack = inventory and inventory:GetOverflowContainer() or nil
local inventorySlotCount = inventory and inventory:GetNumSlots() or 0
local backpackSlotCount = backpack and backpack:GetNumSlots() or 0
local b_removepack = flag == 1 or flag == 3
local b_removeinv = flag == 2 or flag == 3

if (b_removepack) then
  for i = 1, backpackSlotCount do
    local item = backpack:GetItemInSlot(i) or nil
    inventory:RemoveItem(item, true)
    if item ~= nil then
      item:Remove()
    end
  end
end

if b_removeinv then
  for i = 1, inventorySlotCount do
    local item = inventory:GetItemInSlot(i) or nil
    inventory:RemoveItem(item, true)
    if item ~= nil then
      item:Remove()
    end
  end
end
]];
      return code:format(flag or 0)
    end,

    



    ["tech"] = function ()
      local code = [[
local p = player
local b = p.components.builder
local t = p.components.talker
if p and b and t then
  t:Say(b.freebuildmode and "None.. shall survive!" or "All too easy")
  print(b.freebuildmode and "Creative Mode:禁用 Disabled" or "Creative Mode:启用 Enabled")
  b:GiveAllRecipes()
end
]]
      return (code);
    end,


    ["move"] = function ()
      local code = [[
local p = player
local b = p.components.builder
local t = p.components.talker
if p and b and t then
  t:Say(b.freebuildmode and "None.. shall survive!" or "All too easy")
  print(b.freebuildmode and "Creative Mode:禁用 Disabled" or "Creative Mode:启用 Enabled")
  b:GiveAllRecipes()
end
]]
      return (code);
    end,    


    ["groups"] = function ()
      local code = [[
require "tprint"
local push = table.insert
local tjoin = table.concat
local p = player
local t = p.components.talker
local groups = TheWorld.selected_ents_groups;
local arr = {}
print(">>>>groups", TheWorld.selected_ents_groups)
for name, group in pairs(groups or {}) do
  push(arr, name)
  print(">>>>", name)
  t_ls(group)
end
if (#arr == 0) then
  push(arr, "nothing") 
end
local info = tjoin(arr, " ")
t:Say(("All I see is %s"):format(info))

]]
      return (code);
    end,  
    ["groupadd"] = function (_, name)
      local prefix = ("local name = %q\n"):format(name)
      local code = [[
local p = player
local t = p.components.talker

local groups = TheWorld.selected_ents_groups
if not (groups) then
  TheWorld.selected_ents_groups = {} 
  groups = TheWorld.selected_ents_groups
  TheWorld.arr_lookat = TheWorld.arr_lookat or {}
  groups["world"] = TheWorld.arr_lookat
end

if not (groups[name]) then
  groups[name] = {}
  t:Say(("New %s here"):format(name))
else
  t:Say(("It's too old for %s… urgh…"):format(name))
end
TheWorld.arr_lookat = groups[name];
]]
      return prefix..code
    end,

    ["stopvote"] = function (_)
      local code = [[
local p = player
local t = p.components.talker
TheNet:StopVote();
t:Say("No one shall be the wiser.")
print("[my console] StopVote")
]]
      return code
    end,
    ["groupdel"] = function (_, name)
      local prefix = ("local name = %q\n"):format(name)
      local code = [[
TheWorld.selected_ents_groups = TheWorld.selected_ents_groups or {} 

local p = player
local t = p.components.talker
local groups = TheWorld.selected_ents_groups
if (groups[name]) then
  groups[name] = nil
  t:Say(("Die, Fool %s… !"):format(name))
else
  t:Say("Ya have a target?")
end
]]
      return prefix..code
    end,
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
  -- inst.inlimbo = true  
  inst.AnimState:SetMultColour(0,0,0,0)

  if (inst.DynamicShadow) then
    inst.DynamicShadow:Enable(false) 
  end
  if (inst.MiniMapEntity) then
    inst.MiniMapEntity:SetEnabled(false)
  end

  -- toggle_components(inst, "globalposition", false)
  toggle_components(inst, "inspectable", false)

  -- inst:Hide()
  print("[hide] hide myself :", inst, inst.components.inspectable, inst.components.globalposition)

  t:Say("I walk in the shadow")
else
  inst:RemoveTag("noplayerindicator")
  inst:RemoveTag("hiding")
  inst:RemoveTag("notarget")
  inst:RemoveTag("ignoretalking")
  inst:AddTag("inspectable")
  -- inst.inlimbo = false    
  inst.AnimState:SetMultColour(1,1,1,1)

  if (inst.DynamicShadow) then
    inst.DynamicShadow:Enable(true) 
  end
  if (inst.MiniMapEntity) then
    inst.MiniMapEntity:SetEnabled(true) 
  end

  -- toggle_components(inst, "globalposition", true)
  toggle_components(inst, "inspectable", true)

  -- inst:Show()
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



    ["cover"] = function (_)
      local code = [[

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



local p = player
local t = p.components.talker
local arr = TheWorld.arr_lookat or {}
local inst = arr[#arr]
if not (inst) then
  t:Say("Show me a target.")
  return 
end

local colours = {inst.AnimState:GetMultColour()}
if not (colours) then
  print("[error] no colours inst: ", inst)
  -- t:Say("I can not blend!")
  return 
end

local visable = (colours[1] ~= 0 
              or colours[2] ~= 0 
              or colours[3] ~= 0 
              or colours[4] ~= 0);

for _, targ in ipairs(arr) do
  inst = targ;

  if (visable) then
    inst:AddTag("noplayerindicator")
    inst:AddTag("hiding")
    inst:AddTag("notarget")
    inst:AddTag("ignoretalking")
    inst:RemoveTag("inspectable")
    inst.inlimbo = true  
    inst.AnimState:SetMultColour(0,0,0,0)

    if (inst.DynamicShadow) then
      inst.DynamicShadow:Enable(false) 
    end
    if (inst.MiniMapEntity) then
      inst.MiniMapEntity:SetEnabled(false)
    end

    -- toggle_components(inst, "globalposition", false)
    -- toggle_components(inst, "inspectable", false)
    toggle_component_by_field(inst, "workable", "workable", false)
    toggle_component_by_field(inst, "teleporter", "enabled", false)
    toggle_component_by_field(inst, "worldmigrator", "enabled", false)
    toggle_component_by_field(inst, "container", "canbeopened", false, false)
    -- toggle_component_by_field(inst, "container", "ignoresound", false, true)
    if (inst.components.worldmigrator) then
      inst.components.worldmigrator:ValidateAndPushEvents()
    end
    if (inst.components.smart_minisign) then
      if (inst.components.smart_minisign.sign) then
        inst.components.smart_minisign.sign:Hide()
      end
      inst:Hide()
    end
    inst:Hide()
    print("[cover] hide item:", inst, inst.components.smart_minisign)

  else
    inst:RemoveTag("noplayerindicator")
    inst:RemoveTag("hiding")
    inst:RemoveTag("notarget")
    inst:RemoveTag("ignoretalking")
    inst:AddTag("inspectable")
    inst.inlimbo = false
    inst.AnimState:SetMultColour(1,1,1,1)

    if (inst.DynamicShadow) then
      inst.DynamicShadow:Enable(true)
    end
    if (inst.MiniMapEntity) then
      inst.MiniMapEntity:SetEnabled(true)
    end

    -- toggle_components(inst, "globalposition", true)
    -- toggle_components(inst, "inspectable", true)
    toggle_component_by_field(inst, "workable", "workable", true)
    toggle_component_by_field(inst, "teleporter", "enabled", true)
    toggle_component_by_field(inst, "worldmigrator", "enabled", true)
    toggle_component_by_field(inst, "container", "canbeopened", true)
    -- toggle_component_by_field(inst, "container", "ignoresound", true)

    if (inst.components.worldmigrator) then
      inst.components.worldmigrator:ValidateAndPushEvents()
    end
    if (inst.components.smart_minisign) then
      if (inst.components.smart_minisign.sign) then
        inst.components.smart_minisign.sign:Show()
      end
      inst:Show()
    end    
    inst:Show()
    print("[cover] show item:", inst)
  end
end

if (visable) then
  t:Say("We must act!")
else
  t:Say("Let's see.")
end




]]

      return code
    end,
    ["inst"] = function (_, snippet)
      local code = [[
local p = player
local t = p.components.talker
local arr = TheWorld.arr_lookat or {}
local inst = arr[#arr]
local i = inst
local com = inst and inst.components
if not (inst) then
  t:Say("Show me a target.")
  return 
end
TheNet:SystemMessage(tostring(inst))
%s
t:Say("Ready to work.")
]]
      return (code):format(snippet or "");
    end,

  }


  local args = {...}
  local create_code_fn = dt[cmd or ""];
  if (create_code_fn) then
    code = create_code_fn(cmd, ...)
  end

  local fn = loadstring(code);
  this.last_rpc_code = code
  if not (fn) then
      print("[myconsole] clientrpc invalid code:", code)
      return 
  end
  TheNet:SendRPCToServer(RPC["MY_CONSOLE"], code) 
end

