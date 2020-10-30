------------------------------------------------------------
-- base
------------------------------------------------------------

local push = table.insert
local tjoin = table.concat


local db = reload("db")

local tm = import("timer")
local removeTimer = tm.removeTimer
local setInterval = tm.setInterval
local setTimeout  = tm.setTimeout

local logger = import("log");

logger.log(_M._path, "server_mods start")
------------------------------------------------------------
-- this
------------------------------------------------------------
this = this or {}
this.tm_portraitdirty = this.tm_portraitdirty or {}

if not (this.eproxy) then
  this.eproxy = import("EventProxy")() 
end

local AddEventListener     = this.eproxy.createfn("")
local AddPrefabPostInit    = this.eproxy.createfn("AddPrefabPostInit")
local AddPlayerPostInit    = this.eproxy.createfn("AddPlayerPostInit")
local AddComponentPostInit = this.eproxy.createfn("AddComponentPostInit")

------------------------------------------------------------
-- func
------------------------------------------------------------
function copy_base(t)
  local t2 = {}
  for k,v in pairs(t) do
    if ( type(v) == "boolean"
      or type(v) == "number"
      or type(v) == "string" ) then
      t2[k] = v 
    end
  end
  return t2
end

function get_client_info(userid)
  local arr_client = TheNet:GetClientTable() or {}
  for i, client in ipairs(arr_client) do
    if (userid == client.userid) then
      return copy_base(client)
    end
  end
end

------------------------------------------------------------
-- api
------------------------------------------------------------

this.eproxy.reset()

-- todo test next time
AddEventListener('ms_playerspawn', function (player, world)
  local userid = player.userid
  local name   = player.name
  local prefab = player.prefab
  local info = get_client_info(userid)
  print("[trace] 111 login", userid, name, prefab, info)  
  t_ls(player)
  print("[trace] 222 login", userid, name, prefab, info)  
  db.send_event("login", userid, name, prefab, info)  
  logger.log(_M._path, "server_mods 111", player)
end)

-- character prefab but not fill user data
AddPlayerPostInit('', function (player) 
  local userid = player.userid
  local name   = player.name
  local prefab = player.prefab
  local info = get_client_info(userid)
  print("[trace] 333 login", userid, name, prefab, info)  
  t_ls(player)
  print("[trace] 444 login", userid, name, prefab, info)  
  db.send_event("login", userid, name, prefab, info)  
  logger.log(_M._path, "server_mods 333", player)
end)

AddComponentPostInit('globalposition', function (GlobalPosition, inst)
  GlobalPosition.PushPortraitDirty = function (self)
    removeTimer(this.tm_portraitdirty[inst])
    this.tm_portraitdirty[inst] = setTimeout(function ()
      if self.globalpositions then
        local pos = self.globalpositions.positions[self.inst.GUID]
        if (pos) then
          pos.portraitdirty:push()
        else
print("[error] globalposition pos is nil", self, self.inst.GUID, pos)   
        end
print("[trace] fix globalposition", self, self.inst.GUID, pos)
      end
    end, 1)
  end

  print("[trace] globalposition", self, inst)
end)




print("[trace] import server_mods/init.lua")

logger.log(_M._path, "server_mods end")
return _M


--[[
import("log").debug()
]]