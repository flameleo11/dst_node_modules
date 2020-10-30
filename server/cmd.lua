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


local ms_lib = reload("server/move_speed")

require "tprint"

------------------------------------------------------------
-- this
------------------------------------------------------------

this = this or {}
if not (this.eproxy) then
  this.eproxy = import("EventProxy")() 
end

local AddEventListener     = this.eproxy.createfn("")
local AddPrefabPostInit    = this.eproxy.createfn("AddPrefabPostInit")
local AddPlayerPostInit    = this.eproxy.createfn("AddPlayerPostInit")
local AddPrefabPostInitAny = this.eproxy.createfn("AddPrefabPostInitAny")

function log(...)
  logger.log(_M._path, ...)
end


this.users = this.users or {}



------------------------------------------------------------
-- config
------------------------------------------------------------

local delimiter = '\n'
local dst_data_path = "./data/"
local demo_reader_path = "./data/server_xxx.in"
local demo_writer_path = "./data/server_xxx.out"

-- todo repick需要消耗出生物品
local cfg_help_info = "可用命令：-help 帮助; -ms 显示速度(含物品坐骑加成); -repick 重选人物(2min之内);"
local cfg_new_info = "-ms 显示速度(含物品坐骑加成)"

local max_repick_count = 2
local max_dist_to_portal = 300;
local max_repick_elapse = 120;

------------------------------------------------------------
-- api
------------------------------------------------------------

-- t_enum(ThePlayer, 100, print, {"multiplayer_portal"})
function t_enum(inst, range, callback, tags, opt) local x, y, z = inst.Transform:GetWorldPosition();local ents = TheSim:FindEntities(x, y, z, range, { unpack(tags or {"hostile"}) }) for i, v in ipairs(ents) do callback(v, i) end end

function enum_unit(inst, range, callback, tags, opt) 
  local x, y, z = inst.Transform:GetWorldPosition();
  local ents = TheSim:FindEntities(x, y, z, range, { unpack(tags or {"hostile"}) }) 
  for i, v in ipairs(ents) do 
    callback(v, i) 
  end 
end

function SystemMessage(msg, delay)
  delay = delay or 0
  setTimeout(function ()
    TheNet:SystemMessage(msg)
  end, delay)
end

function TalkerSay(userid, msg)
  local p = UserToPlayer(userid)
  if (p) then
    local t = p.components.talker
    return t and t:Say(msg);
  end
end

function showUserMoveSpeed(userid)
  local inst = UserToPlayer(userid)
  if (inst) then
    local msg = ms_lib.GetRunSpeedInfo(inst)
    SystemMessage(msg)
  end
end


------------------------------------------------------------
-- proc
------------------------------------------------------------


function addChatCommand(cmd)
  
end



-- todo repick need cost start items
function repickUser(userid)
  if not (TheWorld and TheWorld.state) then
    print("[cmd] repick failed: TheWorld not exists")
    return
  end

  local p = UserToPlayer(userid)
  if not (p) then 
    print("[cmd] repick failed: player not in this server")
    return
  end

   -- print(GetTime(), GetTime()-p.spawntime)
  local repick_elapse = math.floor(GetTime() - p.spawntime)
  if not (repick_elapse < max_repick_elapse) then
    local msg = ("使用时间%ss超过%ss"):format(repick_elapse, max_repick_elapse)
    SystemMessage(msg)
    print("[cmd] repick failed: player not in this server")
    return 
  end

  -- if not (TheWorld.state.round == 0 and TheWorld.state.cycles < 5) then
  --   SystemMessage("游戏开始5天后无法使用命令 -repick 重选人物")
  --   print("[cmd] repick failed: player not in this server")
  --   return 
  -- end

  local b_nearPortal = false
  enum_unit(p, max_dist_to_portal, function (inst)
    b_nearPortal = true
  end, {"multiplayer_portal"})

  if not (b_nearPortal) then
    SystemMessage("只有在大门附近才可以使用命令 -repick 重选人物")
    print("[cmd] repick failed: player not close to multiplayer portal")
    return 
  end

  this.users[userid] = this.users[userid] or {}
  local mem = this.users[userid]
  local repick_count = mem.repick_count or 0

  if (repick_count >= max_repick_count) then
    local msg = ("你已经重置了%d次，无法再次重置"):format(max_repick_count)
    SystemMessage(msg)
    print("[cmd] repick failed: player not close to multiplayer portal")
    return 
  end

  repick_count = repick_count + 1;
  mem.repick_count = repick_count;

  local name = p.name or "玩家"
  TheWorld:PushEvent("ms_playerdespawnanddelete", p)
  local msg = ("%s已经repick了%d次，还剩%d次"):format(name, repick_count, max_repick_count-repick_count)
  SystemMessage(msg, 10)

  -- SystemMessage("repick ok")
  print("[cmd] repick: ok");

  -- t:Say(godmode and "My wait is over." or "I shall not fear.")

end


------------------------------------------------------------
-- events
------------------------------------------------------------

this.eproxy.reset()

-- eventmgr.emit('Networking_Say', guid, userid, name, prefab, message, colour, whisper, isemote, user_vanity)
AddEventListener('Networking_Say', function (guid, userid, name, prefab, message, colour, whisper, isemote, user_vanity)

  -- todo api for add server user cmd
  if (message == "-load") then
    local p = UserToPlayer(userid)
    if (p) then
      print("........do load..maybe check play age and position..")
    else
      print("........do load....")
    end
  end

  if (message == "-repick") then

    repickUser(userid)
  end

  if (message == "-ms") then
    showUserMoveSpeed(userid)
  end

  if (message == "-help" or message == "-h" or message == "help") then
    local b1 = TheNet:GetIsServer() and "server" or "client"
    local b2 = TheWorld.worldprefab or "nil_worldprefab"    

    local p = UserToPlayer(userid)
    if not (p) then
      print("player not in "..b1..b2)
      return 
    end

    SystemMessage(cfg_help_info)
    print("......-help in "..b1..b2)
  end

  -- print(userid == "KU__9qL15UL", userid)
  if (message == "r" and userid == "KU__9qL15UL") then
    local b1 = TheNet:GetIsServer() and "server" or "client"
    local b2 = TheWorld.worldprefab or "nil_worldprefab"    

    reload("server/cmd")

    local msg = "show reload in "..b1..b2
    TalkerSay(userid, msg)

    -- local p = UserToPlayer(userid)
    -- if (p) then
    --   local t = p.components.talker
    --   local msg = "show reload in "..b1..b2
    --   t:Say(msg)
    -- end
  end
end)




------------------------------------------------------------
-- temp
------------------------------------------------------------

-- todo: rewrite by next day event

removeTimer(this.timer1)
this.timer1 = setTimeout(function (elapse_sec)
  c_announce(cfg_new_info)
end, 30)



removeTimer(this.timer2)
this.timer2 = setInterval(function (elapse_sec)

  -- -- todo:  arr_client only host and admin then restart
  --   -- then admin auto afk
  -- if not (TheWorld.state.cycles > 3) then
  --   local arr_client = TheNet:GetClientTable() or {}
  --   return 
  -- end

  c_announce(cfg_new_info)


end, 300)


log("server.cmd ok ver 0.1")


--[[


function load_fn(cmd, ...)
  local create_code_fn = reload("rpc/fn/"..cmd);
  return create_code_fn;
end

--]]



return _M
